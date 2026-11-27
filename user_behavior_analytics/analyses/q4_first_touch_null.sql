-- 탐색 4. user_first_touch_timestamp가 NULL인 행·유저 수 (dry run 스캔량 약 0.114 GiB)
-- 실행일: 2026-11-27 / 결과 요약: analyses/README.md

SELECT
  COUNT(*) AS total_rows,
  COUNTIF(user_first_touch_timestamp IS NULL) AS null_rows,
  COUNT(DISTINCT user_pseudo_id) AS users,
  COUNT(DISTINCT IF(user_first_touch_timestamp IS NULL, user_pseudo_id, NULL)) AS users_with_null_rows
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
