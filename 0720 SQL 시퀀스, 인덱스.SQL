SQL 기타 객체의 생성 및 관리

1.시퀀스
-자동적으로 유일번호 생성
-공유가능 객체
-기본키값 생성하기 위해 사용
-어플리케이션 코드 대체
-메모리에 CACHE되면 시퀀스 값 액세스 효율성 향상

CREATE  SEQUENCE
        INCREMENT BY n
        START WITH n
        MAXVALUE n
        NOCACHE
        NOCYCLE;


1)NEXTVAL 과 CURRVAL 의사열
특징
-NEXTVAL는 다음 사용 가능한 시퀀스 값 반환
-시퀀스가 참조될 때마다 다른 사용자에게도 유일값 반환
-CURRVAL은 현재 시퀀스 값 반환



CREATE TABLE INDEX_CON (
C1 NUMBER,
C2 NUMBER,
CONSTRAINT INDEX_CON_PK PRIMARY KEY (C1)); --PK만 지정해주었지만 인덱스도 같이 생성됨

SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME = 'INDEX_CON'; --CONSTRAINTS 자체가 인덱스는 아니다.

SELECT * FROM USER_INDEXES WHERE TABLE_NAME = 'INDEX_COM';



시노님 생성
CREATE [PUBLIC] SYNONYM TEMP
FOR STUDY01.TEMP;

이후 
SELECT * FROM TEMP; -- STUDY01의 TEMP를 검색

시노님 삭제
DROP [PUBLIC] SYNONYM TEMPORARY

--PUBLIC은 DBA만 가능하다.

CREATE SEQUENCE S2
        INCREMENT BY 1
        START WITH 999001
        MAXVALUE 99999999
        NOCACHE
        NOCYCLE;
        

SET SERVEROUTPUT ON
DECLARE
    S_NVAL NUMBER;
    S_CVAL NUMBER;
BEGIN
    FOR I IN 1..100
    LOOP
        SELECT S1.NEXTVAL, S1.CURRVAL
        INTO    S_NVAL,S_CVAL
        FROM DUAL;
        
        DBMS_OUTPUT.PUT_LINE('LOOP INDEX : ' || I ||
                             ', NEXTVALUE:' || S_NVAL ||
                             ', CURRVALUE:' || S_CVAL 
                             );
    END LOOP;
END;


SELECT MAX(NO) FROM T1_DATA;



INSERT INTO T1_DATA
SELECT S2.NEXTVAL,
A.EMP_ID, A.EMP_NAME, A.SALARY, A.BIRTH_DATE, A.TABLE_NAME,
A.TABLESPACE_NAME, A.YYMM_YM, A.ITEM_CD, A.BUDGET_CD, A.PROD_AM
FROM T1_DATA A
WHERE A.NO <=10;



SELECT * 
FROM T1_DATA
WHERE NO >= 999001;


CREATE TABLE INDEX_CON (
C1 NUMBER,
C2 NUMBER,
CONSTRAINT INDEX_CON_PK PRIMARY KEY (C1)); --PK만 지정해주었지만 인덱스도 같이 생성됨

SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME = 'INDEX_CON'; --CONSTRAINTS 자체가 인덱스는 아니다.

SELECT * FROM USER_INDEXES WHERE TABLE_NAME = 'INDEX_COM';