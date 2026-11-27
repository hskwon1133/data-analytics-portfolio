-- 탐색 3. session_engaged 값이 어떤 타입·값으로 들어 있는지 (dry run 스캔량 약 1.314 GiB)
-- 실행일: 2026-11-27 / 결과 요약: analyses/README.md

SELECT
  ep.value.string_value AS string_value,
  ep.value.int_value    AS int_value,
  COUNT(*) AS n
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`, UNNEST(event_params) AS ep
WHERE ep.key = 'session_engaged'
GROUP BY 1, 2
ORDER BY n DESC
