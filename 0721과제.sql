pre condition

1. STUDY03에  TDEPT의 SELECT 와 RESOURCE GRANT 

GRANT RESOURCE

TO STUDY03;

GRANT SELECT

TO STUDY03;



2. STUDY03에 CREATE PUBLIC SYNONYM 권한 부여 
   --GRANT CREATE PUBLIC SYNONYM  TO STUDY03


   

보너스 과제
1. STUDY03에서 TDEPT의 자료를 SELECT 하여 동일 이름으로 TABLE을 만들되 
   AREA가 인천인 경우만 입력되도록 CREATE TABLE 문 작성

   CREATE TABLE TDEPT03
    AS SELECT * FROM TDEPT
    WHERE AREA = '인천';



2. TDEPT 에서 모든 자료를 검색해 어느 유저의 테이블인지 확인


SELECT owner
FROM   all_OBJECTS
WHERE  OBJECT_TYPE = 'TABLE'
AND    OBJECT_NAME = 'TDEPT';



3. STUDY03에서 TDEPT에 대한 PUBLIC SYNONYM을 TDEPT라고 생성

CREATE PUBLIC SYNONYM TDEPT FOR STUDY03.TDEPT;




4. SYNONYM의 운선 순위 스스로 확인
   1) STUDY02에서 STUDY01.TDEPT를 대상으로 SYNONYM 생성

   CREATE SYNONYM TDEPT FOR STUDY01.TDEPT;

   2) STUDY03에서 STUDY03.TDEPT 대상으로 PUBLIC SYNONYM 생성

    CREATE PUBLIC SYNONYM TDEPT FOR STUDY03.TDEPT;

   3) 일반 시노님과 PUBLIC 시노님의 경합 : 
      STUDY02에서 TDEPT SELECT

SELECT * FROM TDEPT;

   4) 테이블과 시노님의 경합
      STUDY01에서 TDEPT SELECT

SELECT * FROM TDEPT;

5. STUDY02에서 TDEPT SYNONYM 제거 

DROP SYNONYM TDEPT;


6. STUDY02에서 TDEPT SELECT 후 STUDY02의 시노님이 제거된 효과 확인

SELECT * FROM TDEPT;

ORA-01775: 동의어가 순환 고리 유형으로 정의되어 있습니다
01775. 00000 -  "looping chain of synonyms"
*Cause:    
*Action:
5행, 15열에서 오류 발생


2] 장난감 공장 생산 관리

1.  생산관리용 계정인 STUDY05 를 생성하여 생산관리 전용 계정으로 
    이용하기 위한 권한을 부여하고, 

    CREATE USER STUDY05 
IDENTIFIED BY STUDY05;

GRANT CREATE SESSION
TO STUDY05;

    OBJECT 를 STUDY05에 CREATE 합니다.(dba권한 부여 안됨)


2. 필요한 테이블을 설계하고 생성하며 필요한 OBECT와 권한도 
   직접 정의하고 생성 및 관리합니다.

   CREATE TABLE ITEM (
                ITEM_CD VARCHAR2(20) PRIMARY KEY,
                ITEM_NM VARCHAR2(20)
                );
    
CREATE TABLE LINE (
                LINE_CD VARCHAR2(20) PRIMARY KEY,
                LINE_NM VARCHAR2(20));


                
CREATE TABLE SPEC (
                SPEC_CD VARCHAR2(20) PRIMARY KEY,
                SPEC_NM VARCHAR2(20)
    );
                
                
CREATE TABLE BOM (
                ITEM_CD VARCHAR2(20) REFERENCES ITEM(ITEM_CD),
                SPEC_CD VARCHAR2(20) REFERENCES SPEC(SPEC_CD),
                LINE_CD VARCHAR2(20) REFERENCES LINE(LINE_CD), 
                ITEM_QTY VARCHAR2(20),
                CONSTRAINT BOM_PK PRIMARY KEY(ITEM_CD,SPEC_CD,LINE_CD)
                );

CREATE TABLE BUY_INFO (
                BUY_DATE DATE,
                ITEM_CD VARCHAR2(20) REFERENCES  ITEM(ITEM_CD),
                ITEM_QTY VARCHAR2(20),
    CONSTRAINT BUY_PK  PRIMARY KEY (ITEM_CD,BUY_DATE)
                );


CREATE TABLE INPUT_PLAN (
                IN_DATE DATE ,
                LINE_CD VARCHAR2(20) REFERENCES      LINE(LINE_CD),
                IN_SEQ VARCHAR2(20),
                SPEC_CD VARCHAR2(20) REFERENCES      SPEC(SPEC_CD),
               
	    CONSTRAINT IP_PK PRIMARY KEY(IN_DATE,LINE_CD,IN_SEQ)
                );

CREATE TABLE LINE_DELI (
                IN_DATA VARCHAR2(20),
                ITEM_CD VARCHAR2(20) REFERENCES      ITEM(ITEM_CD),
                DELI_SEQ VARCHAR2(20),
                LINE_CD VARCHAR2(20) REFERENCES      LINE(LINE_CD),
                ITEM_QTY VARCHAR2(20),
	   CONSTRAINT LINE_DELI_PK PRIMARY KEY (IN_DATA, ITEM_CD, LINE_CD, DELI_SEQ)
                );

--CREATE TABLE FACTORY (
                           FACTORY_CD VARCHAR2(20) PRIMARY KEY,
                           FACTORY_NM VARCHAR2(20)
   );






3. 생성된 테이블에 DATA 입력
   -- 공장(P1,P2,P3..), 
      라인(L1,L2,L3..), 
      item(I01,I02,I03...), 
      spec(S01,S02,S03....) 
      bom 정보 생성
     ( 반드시 select 문과 join을 이용한 insert 문 이용) 

     INSERT INTO ITEM
SELECT 'I'||LPAD(ROWNUM,2,0),
        ROWNUM||'번째 아이템'
FROM STUDY01.TEMP
WHERE ROWNUM<=40;

INSERT INTO LINE
SELECT 'L'||LPAD(ROWNUM,2,0),
        ROWNUM||'번째 라인'
FROM STUDY01.TEMP
WHERE ROWNUM<=3;

INSERT INTO SPEC
SELECT 'S'||LPAD(ROWNUM,2,0),
        ROWNUM||'번째 스펙'
FROM STUDY01.TEMP
WHERE ROWNUM<=40;




INSERT INTO BOM   
SELECT ITEM_CD, SPEC_CD,LINE_CD,ROUND(DBMS_RANDOM.VALUE(10,100))
FROM ITEM, SPEC,LINE;  


--INSERT BUY_INFO   
SELECT TO_DATE(TO_CHAR(ADD_MONTHS(SYSDATE,-1),'YYYYMM')||LPAD(ROUND(DBMS_RANDOM.VALUE(1,30)),2,'0')) B_DATE, 
       ITEM_CD,
ROUND(DBMS_R






     
4. 매일 각 생산 라인은 SPEC 중 3가지 종류 SPEC 까지만 생산 가능하다는 가정하에 라인을 100% 가동하는 
   2020년 8월1일부터 10일까지의 10일치 투입계획 수립
   (insert ..select 문과 pl/sql 블록만 이용 가능)

   INSERT INTO INPUT_PLAN
SELECT '2020008' || LPAD(UD.NO,2,'0') IN_DATE, --앞에 202008  +  01~10까지 생성
        L.LINE_CD,
        US.NO IN_SEQ,
        B.SPEC_CD

FROM STUDY01.T1_DATA UD,    --STUDY01의 T1_DATA 테이블 사용
     STUDY01.T1_DATA US,    --STUDY01의 T1_DATA 테이블 사용
     LINE    L,
     (SELECT LINE_CD, SPEC_CD --중복 제거된 LINE CD 와 SPEC CD 를 가져옴
        FROM (SELECT DISTINCT LINE_CD, SPEC_CD ---중복제거 목적 + LINE 1개당 모든SPEC CODE(40개) 대응시켜서 출력
            FROM BOM
            ORDER BY 1,2)
            ) B

WHERE UD.NO <=10 --10일까지 주는 날짜 조건
AND   US.NO <=10 --10회차까지 주기위한 조건

AND   B.LINE_CD = L.LINE_CD --중복제거 하여 가져온 LINE CD(B.LINE_CD)의 데이터와 LINE CD(L.LINE_CD) 테이블의 LINE_NM 데이터 대입

AND   TO_NUMBER(SUBSTR(B.SPEC_CD,2))    --SPEC_CD (S01) 에서 S0 을 제거하여 나오는 숫자 1,2,3...을 숫자타입으로 변환

    BETWEEN 3 * TO_NUMBER(SUBSTR(L.LINE_CD,2)) - 2 --3 * 숫자 -2 >> Y = 3X-2
        AND 3 * TO_NUMBER(SUBSTR(L.LINE_CD,2)) -- 3 * 숫자 
        --위의 BETWEEN 문은 이런 숫자 시작점을 선택 하는 것 
        --예를 들자면 1부터 시작하여 1,2,3 혹은 4부터 시작하여 4,5,6 이렇게 연속적으로 숫자를 가져오되, 시작하는 숫자는 다르게 생성

AND MOD(TO_NUMBER(SUBSTR(B.SPEC_CD,2)),3) = MOD(US.NO,3)--US.NO를 3으로 나눈 나머지가 B.SPEC_CD의 숫자(S03) 과 같은 값을 가져오게끔 하여 
--IN_SEQ와 SPEC_CD를 맞춰주기위함
ORDER BY 1,2,3;--순서 정렬


5. 투입 일자별로 필요 ITEM의 수량을 정리해 1달 전 일자로 
   구매 요청일자를 만들어 
   구매팀에 전달할 data 생성 insert..select 문 생성 

   SELECT ADD_MONTHS(TO_DATE(A.IN_DATE,'YYYYMMDD'),-1),
       B.ITEM_CD,
       SUM(B.ITEM_QTY) ITEM_QTY
FROM INPUT_PLAN A,
     BOM B
WHERE A.IN_DATE LIKE '202008%'
    AND B.LINE_CD = A.LINE_CD
    AND B.SPEC_CD = A.SPEC_CD
GROUP BY ADD_MONTHS(TO_DATE(A.IN_DATE,'YYYYMMDD'),-1),
       B.ITEM_CD;



SELECT ITEM_CD, SUM(ITEM_QTY)
FROM BOM
WHERE LINE_CD = 'L01'
AND SPEC_CD IN ('S01','S02')
GROUP BY ITEM_CD
ORDER BY 1;

   
6. 투입계획과 BOM을 연계하여 일자별 라인별 필요부품 및 부품 개수를 추출해 
   일자별 라인별 부품 조달계획 수립하되
   JIT 생산을 지원하기 위한 5회 분할 조달을 가정한 
   일자별 생산 라인별 회차별 라인별 부품 조달 계획 data 생성
   (insert ..select 문과 pl/sql 블록만 이용 가능)



   