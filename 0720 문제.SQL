--B-4. STUDY01은 인사시스템을 관리하는 USER 이며, STUDY03는 재무시스템을 관리하는 USER 입니다.
--재무시스템에서 인사정보 DB에 대한 사용을 요청합니다.

--특히, 채용구분이 정규가 아닌 임시(임시직)인 경우는 재무시스템에서


--직접 데이터를 입력하고 사용 여부를 관리할 수 있도록 해 달라고 요청합니다.

--또한 모든 직원 정보의 급여, 커미션, 직급별 급여 범위 등 돈과 관련된 모든 정보를 재무시스템에서
--변경은 못해도 확인할 수 있어야 한다고 요청 중입니다.

--인사시스템 DATA 관리 담당자 입장이 되어 재무시스템의 요청을 해결해 줄 수 있는 방법을 강구하고 이를 DB에 구현합니다.
--조별 발표를 통해 구현한 내용을 설명하고 왜 그렇게 구현했는지에 대해 발표와 DEMO







--4-1. 각 조는 자신들이 이해한 대로 문제를 통해 요구 사항을 추립니다

--사원 조회(수정가능), 사원조회(readonloy), 인턴 조회

--4-2. 요구 사항에 대응하기 위한 기술적 대응 방안을 수립합니다

--4-3. 각 대응 방안이 통합 가능한지를 판단하고 대응을 요구사항 별로 할지 통합적 방법으로 할 지 결정합니다

--4-4. 대응 방안대로 구현하고 조별 발표 시는 구현 내용과 데모를 시현합니다.


--수정가능한 사원 정보 뷰(수정가능)
CREATE OR REPLACE VIEW 사원뷰 (사번, 사원이름, 생일, 부서코드, 급여, 사용여부, 전화번호, 직급, 취미, 채용형태)
            AS SELECT EMP_ID, EMP_NAME, BIRTH_DATE, DEPT_CODE, SALARY, USE_YN, TEL, LEV, HOBBY, EMP_TYPE
            FROM TEMP              
            ;
            
            SELECT * FROM 사원뷰;


--인턴인 사원만 조회가능한 뷰(수정불가)
CREATE OR REPLACE VIEW 인턴조회 (사번, 사원이름, 급여, 직급, 커미션, 급여하한, 급여상한, 채용형태)
            AS SELECT TT.EMP_ID, TT.EMP_NAME, TT.SALARY, TT.LEV, TC.COMM, EL.FROM_SAL, EL.TO_SAL, TT.EMP_TYPE
            FROM TEMP TT, TCOM TC, EMP_LEVEL EL
            WHERE   TT.EMP_ID = TC.EMP_ID(+)
            AND     TT.LEV = EL.LEV(+)
            AND     TC.WORK_YEAR(+) = '2020'
            AND     TT.EMP_TYPE = '인턴'
            ;            
            
            SELECT * FROM 인턴조회;
            
--전체 인원 조회(재무정보)
CREATE OR REPLACE VIEW 사원재무정보(사번, 사원이름, 급여, 직급, 커미션, 급여하한, 급여상한, 채용형태)
            AS SELECT TT.EMP_ID, TT.EMP_NAME, TT.SALARY, TT.LEV, TC.COMM, EL.FROM_SAL, EL.TO_SAL, TT.EMP_TYPE
            FROM TEMP TT, TCOM TC, EMP_LEVEL EL
            WHERE   TT.EMP_ID = TC.EMP_ID(+)
            AND     TT.LEV = EL.LEV(+)
            AND     TC.WORK_YEAR(+) = '2020'
            
            ;
            
            SELECT * FROM 사원재무정보;
            
--사원 조회만 가능한 뷰(수정불가)
CREATE OR REPLACE VIEW 사원뷰_READONLY (사번, 사원이름, 생일, 부서코드, 급여, 사용여부, 전화번호, 직급, 취미, 채용형태)
            AS SELECT EMP_ID, EMP_NAME, BIRTH_DATE, DEPT_CODE, SALARY, USE_YN, TEL, LEV, HOBBY, EMP_TYPE
            FROM TEMP
            WITH READ ONLY
            ;
            
            SELECT * FROM 사원뷰_READONLY;
            
INSERT INTO 사원뷰_READONLY VALUES (1912111,	'비비비',	  '',	'CA0001',	64000000,'Y',0101234567,'축구',	'차장','정규')
            

GRANT CREATE VIEW
TO STUDY03;
            
            
        



DROP VIEW FINANCE1;


 --1 인턴있는 뷰
 
 --2 모든 직원 뷰
 
 --3 롤 
 
 
 --권한주기

CREATE ROLE VIEW_ONLY;

CREATE ROLE MODI_ALBE;

GRANT SELECT
TO VIEW_ONLY;

GRANT ALTER USER
TO STUDY03;

SELECT * FROM DBA_ROLE_PRIVS;

--INSERT INTO 시 키-보존 에러가 생성시 
--VIEW생성의 SELECT문의 키 보존 값이제대로 들어왔는지 , VALUE 와 해야함

CREATE SEQUENCE EMP_IDD
       INCREMENT BY 1
       START WITH 10
       MAXVALUE 100
       NOCACHE
       NOCYCLE;
       
SELECT SEQUENCE_NAME, MIN_VALUE, MAX_VALUE, INCREMENT_BY, LAST_NUMBER
FROM USER_SEQUENCES;

SELECT EMP_IDD.NEXTVAL FROM DUAL;

SELECT EMP_IDD.CURRVAL FROM DUAL

SELECT COUNT(*) FROM T1_DATA;

SELECT MAX(NO) FROM T1_DATA;


SELECT 'A' ||COLUMN_NAME||','
FROM USER_TAB_COLUMNS
WHERE TABLE_NAME = 'T1_DATA';

INSERT INTO T1_DATA
SELECT 999*B.NO + A.NO,
A.EMP_ID, A.EMP_NAME, A.SALARY, A.BIRTH_DATE, A.TABLE_NAME,
A.TABLESPACE_NAME, A.YYMM_YM, A.ITEM_CD, A.BUDGET_CD, A.PROD_AM
FROM T1_DATA A, T1_DATA B
WHERE B.NO <=1000;

ROLLBACK;