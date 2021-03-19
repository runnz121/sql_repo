1]


1.  직원의 소속부서가 변경될 때 마다 현재상태 관리자 정보를 
    별도로 보관하기 위한 HISTORY 테이블 생성  
    TMAN_HISTORY(CHANGE_DATE VARCHAR2(08), EMP_ID NUMBER, DEPT_CODE VARCHAR(20), BOSS_ID NUMBER, IS_NOW VARCHAR2(01) ); 
2.  직원의  연봉 정보가 변경될 때 마다 연봉 변경일자와 변경 전.후 금액을 보관하는 HISTORY
     테이블 생성  
    TSAL_HISTORY(CHANGE_DATE VARCHAR2(08), EMP_ID NUMBER, BEF_SALARY NUMBER, AFT_SALARY NUMBER)
3.  현재 직원정보를 읽어 직급이 사원인 경우 HISTORY 테이블 두 곳에 현재 상태 정보 입력
     (변경일자:현재일자,  IS_NOW:‘Y’,  BEF_SALARY:0,  AFT_SALARY:현재SALARY)
4.  현재 직원정보를 읽어 직급이 대리인 경우 HISTORY 테이블 두 곳에 현재 상태 정보 입력하되
    TMAN_HISTORY에는 AA0001 부서만을 대상으로 TSAL_HISTORY에는 
    SALARY가 5천만원 이상인 경우만을 대상으로 동시 인서트 수행

2]

1. 현재 직원정보를 읽어 직급이 과장인 경우 HISTORY 테이블 
   두 곳에 현재 상태 정보를 입력하되
    TMAN_HISTORY에는 AA0001 부서만을 대상으로 
    TSAL_HISTORY에는 SALARY가 5천만원 이상인 경우만을 대상으로 
    동시 인서트 수행 (단, 첫 번째  TMAN에 입력된 경우 TSAL 입력 안함)
2. T2_DATA를 ROW형식으로 관리하기 위한 테이블 생성 
    T2_TRAN (EMP_ID NUMBER, YM VARCHAR2(06), MSAL NUMBER)
3. T2_DATA를 INSERT ALL 문장이용 T2_TRAN 으로 INSERT