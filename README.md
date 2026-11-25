# User Behavior Analytics

공개 데이터로 앱/웹 유저 행동을 분석하고 A/B 테스트를 수행하는 포트폴리오 프로젝트입니다.

> 진행 중입니다. 아래 내용 중 결과가 적히지 않은 항목은 아직 수행하지 않은 것입니다.

## 프로젝트 구성

| 주제 | 내용 | 상태 |
|---|---|---|
| 유저 행동 분석 | dbt + BigQuery로 이벤트 데이터 모델링 (staging → marts) | 예정 |
| A/B 테스트 | Cookie Cats 모바일 게임 실험 데이터 분석 | 예정 |

## 폴더 구조

```
.
├── dbt/                          # dbt 프로젝트
│   └── models/
│       ├── staging/              # 원천 데이터 정제
│       └── marts/                # 분석용 집계 테이블
└── analysis/
    └── ab_test_cookie_cats/      # A/B 테스트 분석 (노트북)
```

## 기술 스택
- BigQuery, dbt (dbt-bigquery)
- Python: pandas, scipy, Jupyter

## 데이터
원본 데이터 파일은 저장소에 포함하지 않습니다.

- **Cookie Cats A/B 테스트**: Kaggle에 공개된 Cookie Cats 데이터셋(`cookie_cats.csv`)을 내려받아 `analysis/ab_test_cookie_cats/data/`에 둡니다.
- **유저 행동 분석 데이터**: TODO (사용할 공개 데이터셋 확정 후 기재)

## 실행 환경 설정

```bash
py -3.13 -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

dbt 접속 정보는 저장소에 포함되어 있지 않습니다. `~/.dbt/profiles.yml`에 `user_behavior_analytics` 프로필(BigQuery, oauth)을 직접 추가해야 합니다.

## 분석 결과
TODO
