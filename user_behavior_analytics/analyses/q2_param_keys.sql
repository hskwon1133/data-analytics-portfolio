-- 탐색 2. event_params key 목록과 key별 값 타입 분포 (dry run 스캔량 약 1.314 GiB)
-- 실행일: 2026-11-27 / 결과 요약: analyses/README.md

SELECT
  ep.key,
  COUNT(*) AS n,
  COUNTIF(ep.value.string_value IS NOT NULL) AS n_string,
  COUNTIF(ep.value.int_value    IS NOT NULL) AS n_int,
  COUNTIF(ep.value.float_value  IS NOT NULL) AS n_float,
  COUNTIF(ep.value.double_value IS NOT NULL) AS n_double
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`, UNNEST(event_params) AS ep
GROUP BY ep.key
ORDER BY n DESC
