UPDATE TDEPT
   SET BOSS_ID = DECODE(DEPT_CODE, 'CEO001', 20010104 ,
                                   'CSO001', 19950302 ,
                                   'CTO001', 19950601 ,
                                   'COO001', 19980602 )
 WHERE DEPT_CODE IN ('COO001','CTO001','CSO001','CEO001')
;
COMMIT;
5 ]
1 과장 직급을 가질만한 나이에 포함되는 사람이 누군지 현재 직급에 관계없이 읽어오기
   (사번,성명,나이,현재직급 만 보여 주세요)
2. TEMP 와 EMP_LEVEL 을 이용해 EMP_LEVEL의 과장 직급의
   연봉 상한/하한 범위 내에 드는 직원의 사번,성명,직급,SALARY, 연봉 하한,연봉 상한 읽기
3. 다음과 같은 부서정보를 보여주고자 합니다.
    적절한 SELECT 문을 작성하시오
    부서코드 / 부서명/ 상위부서 / 상위부서명 / 상위부서BOSS_ID / BOSS 이름
