-- 탐색 1. event_name 종류와 이벤트 건수 (dry run 스캔량 약 0.052 GiB)
-- 실행일: 2026-11-27 / 결과 요약: analyses/README.md

SELECT event_name, COUNT(*) AS n
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
GROUP BY event_name
ORDER BY n DESC
