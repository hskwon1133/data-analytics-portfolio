# 작업 규칙

공개 데이터로 앱/웹 유저 행동 분석과 A/B 테스트를 하는 포트폴리오 프로젝트.

## 커밋 / push
- 작업 단위마다 커밋한다. push는 하루 작업이 끝날 때 한 번 한다.
- 사용자가 직접 작성한 SQL·코드는 **수정하지 않고 리뷰만** 한다. 제안은 리뷰 코멘트로 전달한다.
- 사용자가 직접 작성한 작업은 Claude 작업과 **별도 커밋**으로 나누고, 커밋 메시지에 `직접 작성`을 표시한다.

## 절대 커밋 금지
- 회사 이름, 개인정보(이름·이메일·연락처 등)
- 외부 원본 데이터 파일(Cookie Cats CSV 등). 데이터는 README에 **받는 방법만** 적는다.
- GCP 프로젝트 ID, 인증 정보(키 파일, `.env`, `profiles.yml`)
- 커밋 전 `git diff --cached`로 위 항목이 섞이지 않았는지 확인한다.

## README 작성
- 실행하지 않은 것을 실행한 것처럼 쓰지 않는다. 결과·수치는 실제로 돌려서 확인한 것만 적고, 아직 안 한 것은 "예정"/TODO로 표시한다.

## 환경
- Python 가상환경: `.venv` (Python 3.13). 패키지 버전은 `requirements.txt`.
- dbt 프로젝트: `user_behavior_analytics/` (모델은 `models/staging`, `models/marts`). 접속 정보는 저장소 밖 `~/.dbt/profiles.yml`의 `user_behavior_analytics` 프로필.
- BigQuery 데이터셋은 `uba_` 접두사(`uba_dev`, `uba_dev_staging`, `uba_dev_marts`)로 기존 프로젝트 데이터셋과 분리한다.
- A/B 테스트 분석: `ab_testing/` (노트북은 `notebook/`, 원본 데이터는 `data/`, gitignore 처리).
- 매출 KPI 파이프라인: `sales_kpi_pipeline/` (예정).
