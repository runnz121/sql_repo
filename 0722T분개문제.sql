1. 테이블 정보

CREATE TABLE JOURNAL(
  CD_AUTOSLIP  VARCHAR2(28) NOT NULL,      -- 자동전표번호
  NO_TRADE     NUMBER(10)   NOT NULL,        -- 전표번호
  NO_SLIP      NUMBER(10)   NOT NULL,          -- 순번
  TY_TRADE_IO          VARCHAR2(4),               -- 항상 'C' : 무시 
  CD_ACCOUNT           VARCHAR2(7),             -- 계정코드
  TY_CRDR              VARCHAR2(4),                 -- 차대구분(C:대변, D:차변)
  DS_AMOUNT            VARCHAR2(50),            -- 비용명
  YN_COST              VARCHAR2(4),                 -- 원가여부
  CONSTRAINT PK_JOURNAL PRIMARY KEY (CD_AUTOSLIP,NO_TRADE,NO_SLIP)
);  


2. 자료 삽입

DECLARE
BEGIN
INSERT INTO JOURNAL VALUES ('ZZZ0001',1,1,'C','9500101','D','이자비용(일반차입이자)','N');
INSERT INTO JOURNAL VALUES ('ZZZ0001',1,2,'C','9500107','D','이자비용(기금차입)','N');
INSERT INTO JOURNAL VALUES ('ZZZ0001',1,3,'C','9500109','D','이자비용(당좌차월이자)','N');
INSERT INTO JOURNAL VALUES ('ZZZ0001',1,4,'C','9500113','D','이자비용(어음할인료)','N');
INSERT INTO JOURNAL VALUES ('ZZZ0001',1,5,'C','9500115','D','이자비용(기타차입이자)','N');
INSERT INTO JOURNAL VALUES ('ZZZ0001',1,6,'C','6400109','C','미지급비용(이자비용)','N');
INSERT INTO JOURNAL VALUES ('ZZZ0001',2,1,'C','9500101','D','-이자비용(일반차입이자)','N');
INSERT INTO JOURNAL VALUES ('ZZZ0001',2,2,'C','9500107','D','-이자비용(기금차입)','N');
INSERT INTO JOURNAL VALUES ('ZZZ0001',2,3,'C','9500109','D','-이자비용(당좌차월이자)','N');
INSERT INTO JOURNAL VALUES ('ZZZ0001',2,4,'C','9500113','D','-이자비용(어음할인료)','N');
INSERT INTO JOURNAL VALUES ('ZZZ0001',2,5,'C','9500115','D','-이자비용(기타차입이자)','N');
INSERT INTO JOURNAL VALUES ('ZZZ0001',2,6,'C','6400109','C','-미지급비용(이자비용)','N');
END;
  
-- 전표번호가 같은 분개정보를 이용해 차변이(D) 오른쪽에 대변이(C) 왼쪽이 오도록 T분개를 보여주고 분개와 분개 사이에 빈 row를 하나씩 삽입

3. one query 실행 결과 : 
  /계정코드/
1	9500115	원가(이자비용(기타차입이자))	6400109	원가(미지급비용(이자비용))
1	9500113	원가(이자비용(어음할인료))		
1	9500109	원가(이자비용(당좌차월이자))		
1	9500107	원가(이자비용(기금차입))		
1	9500101	원가(이자비용(일반차입이자))		
0	 	 	 	 
2	9500115	원가(-이자비용(기타차입이자))	6400109	원가(-미지급비용(이자비용))
2	9500113	원가(-이자비용(어음할인료))		
2	9500109	원가(-이자비용(당좌차월이자))		
2	9500107	원가(-이자비용(기금차입))		
2	9500101	원가(-이자비용(일반차입이자))


--내가 작성한 QUERY 여기서 차변을 오른쪽으로 출력하게끔 GROUP 짓는것이 문제였음
SELECT NO_TRADE, 

       ROW_NUMBER()    OVER(PARTITION BY NO_TRADE,TY_CRDR ORDER BY NO_TRADE) AS ROWNUM1,
       
       CD_ACCOUNT 계정코드,
       
       DECODE(TY_CRDR,'D','원가('||DS_AMOUNT||')') AS 차D변,
       
       CD_ACCOUNT 계정코드,
       
       DECODE(TY_CRDR,'C','원가('||DS_AMOUNT||')') AS 대변



FROM JOURNAL
;


--답안

SELECT NO_TRADE, RNO, 
       MAX(DECODE(TY_CRDR, 'D', CD_ACNT)),
       MAX(DECODE(TY_CRDR, 'D', DS_ACNT)),
       MAX(DECODE(TY_CRDR, 'C', CD_ACNT)),
       MAX(DECODE(TY_CRDR, 'C', DS_ACNT))
FROM(
SELECT ROW_NUMBER() OVER(PARTITION BY NO_TRADE, TY_CRDR ORDER BY NO_TRADE, TY_CRDR DESC)
RNO,--거래번호/차대 별로 순번 부여

        MAX(NO_TRADE) OVER() MTR, --거래번호의
        A.NO_TRADE, A.TY_CRDR, A.YN_COST, A.CD_ACCOUNT CD_ACNT, 
        '원가('||DS_AMOUNT||')' DS_ACNT
        FROM JOURNAL A
        WHERE A.YN_COST ='N'
        )
        GROUP BY NO_TRADE, RNO
        ORDER BY NO_TRADE, RNO;

1	1	NULL    6400109	원가(미지급비용(이자비용))
1	1	9500115	원가(이자비용(기타차입이자))		
1	2	9500113	원가(이자비용(어음할인료))		
1	3	9500109	원가(이자비용(당좌차월이자))		
1	4	9500107	원가(이자비용(기금차입))		
1	5	9500101	원가(이자비용(일반차입이자))		
2	1	NULL	6400109	원가(-미지급비용(이자비용))
2	1	9500115	원가(-이자비용(기타차입이자))		
2	2	9500113	원가(-이자비용(어음할인료))		
2	3	9500109	원가(-이자비용(당좌차월이자))		
2	4	9500107	원가(-이자비용(기금차입))		
2	5	9500101	원가(-이자비용(일반차입이자))		

        
--완성 답안--
SELECT DECODE(RNO,NULL,0,NO_TRADE) NO_TRADE,
       DECODE(RNO,NULL,NULL,D_CD) D_CD,
       DECODE(RNO,NULL,NULL,D_DS) D_DS,
       DECODE(RNO,NULL,NULL,C_CD) C_CD,
       DECODE(RNO,NULL,NULL,C_DS) C_DS
      
FROM(
        SELECT NO_TRADE, RNO, 
            MAX(DECODE(TY_CRDR, 'D', CD_ACNT)) D_CD,
            MAX(DECODE(TY_CRDR, 'D', DS_ACNT)) D_DS,
            MAX(DECODE(TY_CRDR, 'C', CD_ACNT)) C_CD,
            MAX(DECODE(TY_CRDR, 'C', DS_ACNT)) C_DS,
            GROUPING(NO_TRADE) + GROUPING(RNO) + DECODE(MAX(MTR),NO_TRADE,1,0) AS CHK
        FROM(
                SELECT ROW_NUMBER() OVER(PARTITION BY NO_TRADE, TY_CRDR ORDER BY NO_TRADE, TY_CRDR DESC) RNO,--NO_TRADE, TY_CRDR로 묶은 후 내림차순 정렬 한것을 순서 부여 하고 이를 RNO로 지정
                    MAX(NO_TRADE) OVER() MTR, --NO_TRADE의 최대값을 MTR로 지정
                    A.NO_TRADE,
                    A.TY_CRDR, 
                    A.YN_COST, 
                    A.CD_ACCOUNT AS CD_ACNT, 
                    '원가('||DS_AMOUNT||')' AS DS_ACNT
                    FROM JOURNAL A
                    WHERE A.YN_COST ='N'
            )

        GROUP BY ROLLUP(NO_TRADE, RNO)
        ORDER BY NO_TRADE, RNO
    )
WHERE CHK <=1;


1	9500115	원가(이자비용(기타차입이자))	6400109	원가(미지급비용(이자비용))
1	9500113	원가(이자비용(어음할인료))		
1	9500109	원가(이자비용(당좌차월이자))		
1	9500107	원가(이자비용(기금차입))		
1	9500101	원가(이자비용(일반차입이자))		
0				
2	9500115	원가(-이자비용(기타차입이자))	6400109	원가(-미지급비용(이자비용))
2	9500113	원가(-이자비용(어음할인료))		
2	9500109	원가(-이자비용(당좌차월이자))		
2	9500107	원가(-이자비용(기금차입))		
2	9500101	원가(-이자비용(일반차입이자))		