# 탐색 쿼리 (analyses)

모델을 만들기 전에 GA4 공개 샘플의 구조를 확인한 쿼리들이다. 모델이 아니므로 `dbt run`으로 테이블이 만들어지지 않는다.

- 대상: `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` (전체 기간)
- 실행일: 2026-11-27. 모든 쿼리는 dry run으로 스캔량을 먼저 확인하고 실행했다.
- 아래 수치는 모두 이 쿼리를 실제로 실행해서 얻은 값이다.

| 파일 | 확인한 것 | 스캔량(dry run) |
|---|---|---|
| [`q1_event_names.sql`](q1_event_names.sql) | event_name별 이벤트 건수 | 약 0.052 GiB |
| [`q2_param_keys.sql`](q2_param_keys.sql) | event_params key 목록과 key별 값 타입 | 약 1.314 GiB |
| [`q3_session_engaged.sql`](q3_session_engaged.sql) | `session_engaged` 값의 타입과 값 | 약 1.314 GiB |
| [`q4_first_touch_null.sql`](q4_first_touch_null.sql) | `user_first_touch_timestamp`가 비어 있는 행 | 약 0.114 GiB |

전체 규모: **4,295,584개 이벤트, 270,154명(`user_pseudo_id`)**.

---

## ⚠️ 지표 정의에 영향을 주는 발견

[상위 README의 지표 정의](../README.md#지표-정의) 중 두 가지가 아래 발견의 영향을 받는다.

### 1. `session_engaged` 값의 타입이 섞여 있다 → DAU·참여 세션 정의에 영향

| string_value | int_value | 건수 |
|---|---|---|
| `'1'` | NULL | 3,110,250 |
| `'0'` | NULL | 572,671 |
| NULL | `1` | 313,391 |

- 대부분은 **문자열**(`'1'`/`'0'`)로 들어 있다. 그러나 313,391건(이 key가 있는 이벤트의 약 7.8%)은 **정수 `1`**로 들어 있다. 정수 `0`은 없다.
- 이 key가 아예 없는 이벤트도 299,272건(전체 이벤트의 약 7.0%)이다. 4,295,584 − 3,996,312로 계산했다.
- **영향:** 지표 정의의 "참여 세션(`session_engaged = 1`)"을 `value.string_value = '1'`로만 구현하면 정수 1로 들어온 31만 건이 빠진다. 그러면 DAU/WAU/MAU와 참여 기준 리텐션이 실제보다 작게 나온다. `value.int_value = 1`로만 구현하면 대부분이 빠진다.
- **구현 시 처리 방향(제안):** 두 칸을 함께 읽는다. 예: `COALESCE(value.string_value, CAST(value.int_value AS STRING)) = '1'`.
- **아직 정하지 않은 것:** 참여 여부를 세션 단위로 판정하는 방법. 예를 들어 그 세션에 `'1'`이 하나라도 있으면 참여 세션으로 볼지 정해야 한다. key가 없는 이벤트를 어떻게 다룰지도 함께 정해야 한다.

### 2. `user_first_touch_timestamp`가 비어 있는 행이 있다 → 코호트 진입 정의에 영향

| 전체 행 | NULL 행 | 전체 유저 | NULL 행이 있는 유저 |
|---|---|---|---|
| 4,295,584 | 86,048 (약 2.0%) | 270,154 | 4,435 (약 1.6%) |

- **영향:** 지표 정의의 코호트 진입 조건은 "`user_first_touch_timestamp`가 2020-11-01 이후인 사용자"다. 값이 NULL이면 이 조건이 참이 아니라서, 해당 행이나 유저가 아무 표시 없이 코호트에서 빠진다.
- **아직 확인하지 않은 것:** 이 4,435명의 **다른 행에는 값이 있는지**. 다른 행에 값이 있으면 유저별 `MIN(user_first_touch_timestamp)`로 보완할 수 있다. 어느 행에도 값이 없는 유저는 제외할지, `first_visit` 이벤트 시각 등으로 대체할지 정해야 한다. → **TODO: 유저 단위 확인 쿼리 추가**

---

## 그 밖의 결과

### event_name (q1)

이벤트 종류는 17개다.

| event_name | 건수 | event_name | 건수 |
|---|---|---|---|
| page_view | 1,350,428 | select_item | 31,007 |
| user_engagement | 1,058,721 | view_search_results | 26,172 |
| scroll | 493,072 | add_shipping_info | 19,722 |
| view_item | 386,068 | add_payment_info | 13,899 |
| session_start | 354,970 | select_promotion | 9,450 |
| first_visit | 257,462 | purchase | 5,692 |
| view_promotion | 190,104 | click | 1,446 |
| add_to_cart | 58,543 | view_item_list | 71 |
| begin_checkout | 38,757 | | |

- 퍼널 단계 이벤트(`view_item` → `add_to_cart` → `begin_checkout` → `purchase`)는 모두 있다. 위 숫자는 **이벤트 건수**이고, 지표 정의의 "사람 기준 퍼널"은 유저 단위로 따로 집계해야 한다.
- `view_item_list`는 71건뿐이어서 퍼널 단계로 쓰기 어렵다.

### event_params key (q2)

key는 34개다.

- **모든 이벤트에 있는 key:** `ga_session_id`, `ga_session_number`, `page_location`. 세션은 `user_pseudo_id` + `ga_session_id`로 구분할 수 있다.
- **값이 하나도 없는 key:** `all_data`, `gclid`, `gclsrc`, `dclid`. 네 가지 값 타입이 모두 비어 있다. 샘플을 난독화하면서 값을 지운 것으로 보인다(추정).
- **일부만 채워진 key:** `page_referrer`는 key가 있는 3,206,512건 중 값이 있는 건이 1,127,778건이다. `page_title`은 1,468건이 비어 있다.
- **값 타입이 섞인 key:** `session_engaged`(string/int, 위 참고), `value`·`tax`(int/double), `transaction_id`(string/int). 이 key들은 staging 모델에서 타입을 하나로 맞춰야 한다.
- `engagement_time_msec`은 2,431,818건이 모두 int다.

<details>
<summary>key별 전체 결과</summary>

| key | n | n_string | n_int | n_float | n_double |
|---|---|---|---|---|---|
| ga_session_number | 4,295,584 | 0 | 4,295,584 | 0 | 0 |
| page_location | 4,295,584 | 4,295,584 | 0 | 0 | 0 |
| ga_session_id | 4,295,584 | 0 | 4,295,584 | 0 | 0 |
| page_title | 4,276,104 | 4,274,636 | 0 | 0 | 0 |
| engaged_session_event | 4,116,237 | 0 | 4,116,237 | 0 | 0 |
| session_engaged | 3,996,312 | 3,682,921 | 313,391 | 0 | 0 |
| debug_mode | 3,682,991 | 0 | 3,682,991 | 0 | 0 |
| page_referrer | 3,206,512 | 1,127,778 | 0 | 0 | 0 |
| all_data | 2,828,174 | 0 | 0 | 0 | 0 |
| clean_event | 2,828,040 | 2,828,040 | 0 | 0 | 0 |
| engagement_time_msec | 2,431,818 | 0 | 2,431,818 | 0 | 0 |
| medium | 1,439,214 | 1,439,214 | 0 | 0 | 0 |
| campaign | 1,439,167 | 1,439,167 | 0 | 0 | 0 |
| source | 1,428,080 | 1,428,080 | 0 | 0 | 0 |
| percent_scrolled | 493,072 | 0 | 493,072 | 0 | 0 |
| term | 338,704 | 338,704 | 0 | 0 | 0 |
| entrances | 332,179 | 0 | 332,179 | 0 | 0 |
| gclid | 118,481 | 0 | 0 | 0 | 0 |
| gclsrc | 116,846 | 0 | 0 | 0 | 0 |
| currency | 39,313 | 39,313 | 0 | 0 | 0 |
| search_term | 26,172 | 26,172 | 0 | 0 | 0 |
| unique_search_term | 20,967 | 0 | 20,967 | 0 | 0 |
| dclid | 15,701 | 0 | 0 | 0 | 0 |
| value | 5,242 | 0 | 1,832 | 0 | 3,410 |
| tax | 5,242 | 0 | 455 | 0 | 4,787 |
| transaction_id | 5,242 | 4,786 | 456 | 0 | 0 |
| payment_type | 5,242 | 5,242 | 0 | 0 | 0 |
| shipping_tier | 4,159 | 4,159 | 0 | 0 | 0 |
| coupon | 3,075 | 3,075 | 0 | 0 | 0 |
| promotion_name | 2,270 | 2,270 | 0 | 0 | 0 |
| outbound | 1,446 | 1,446 | 0 | 0 | 0 |
| link_url | 1,446 | 1,446 | 0 | 0 | 0 |
| link_domain | 1,446 | 1,446 | 0 | 0 | 0 |
| link_classes | 6 | 6 | 0 | 0 | 0 |

</details>

## 다음 할 일 (예정)

- [ ] `user_first_touch_timestamp` NULL 유저가 다른 행에서는 값을 가지는지 유저 단위로 확인
- [ ] 세션 단위 참여 판정 규칙 결정 (`session_engaged` 타입 통합 포함)
- [ ] `value`·`tax`·`transaction_id` 타입 통합 방식을 staging 모델에 반영
