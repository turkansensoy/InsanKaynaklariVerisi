use HR;
SELECT  *FROM PERSON
-----------------------------------------------------------------------------------------------------------------------------------------
-- �irketimizde halen �al��maya devam eden �al��anlar�n listesini getiren sorgu?
SELECT *FROM PERSON WHERE OUTDATE IS NULL;
-----------------------------------------------------------------------------------------------------------------------------------------
-- �irketimizde departman bazl� halen �al��maya devam eden KADIN ve ERKEK say�lar�n� getirme.
SELECT D.DEPARTMENT,
 CASE
  WHEN P.GENDER='K' THEN 'KADIN'
  WHEN P.GENDER='E' THEN 'ERKEK'
 END AS GENDER, COUNT(P.ID) FROM PERSON P 
INNER JOIN DEPARTMENT D ON P.DEPARTMENTID=D.ID WHERE P.OUTDATE IS NULL GROUP BY D.DEPARTMENT, P.GENDER ORDER BY D.DEPARTMENT
-----------------------------------------------------------------------------------------------------------------------------------------
-- �irketimizde departman bazl� halen �al��maya devam eden KADIN ve ERKEK say�lar�n� getirme Ayr� ayr� getirme.
SELECT *,(SELECT COUNT(*) FROM PERSON WHERE GENDER='K' AND DEPARTMENTID=D.ID AND OUTDATE IS NULL) AS KADINSAYISI,
    (SELECT COUNT(*) FROM PERSON WHERE GENDER='E'AND DEPARTMENTID=D.ID AND OUTDATE IS NULL) AS ERKEK_SAYISI,
    (SELECT COUNT(*) FROM PERSON WHERE DEPARTMENTID=D.ID AND OUTDATE IS NULL) AS T�M_DURUM
	FROM DEPARTMENT D
-----------------------------------------------------------------------------------------------------------------------------------------
--�irketimizin Planlama departman�na yeni bir �ef atamas� yap�ld� ve maa��n� belirlemek istiyoruz.
--Planlama departman� i�in minimum, maximum ve ortalama �ef maa�� getiren sorgu
-- NOT ��ten ��km�� olan personel maa�lar� da dahil.
SELECT PO.POSITION,MIN(SALARY) AS M�N, MAX(SALARY) AS MAX, ROUND(AVG(SALARY),0) AS ORTALAMA FROM PERSON P INNER JOIN POSITION PO
ON P.POSITIONID=PO.ID WHERE PO.POSITION= 'PLANLAMA �EF�' GROUP BY PO.POSITION 
--OR
SELECT PO.POSITION,
(SELECT MIN(SALARY) FROM PERSON WHERE POSITIONID=PO.ID ) AS MIN�,
(SELECT MAX(SALARY) FROM PERSON WHERE POSITIONID=PO.ID ) AS MAX�,
(SELECT ROUND(AVG(SALARY),0) FROM PERSON WHERE POSITIONID=PO.ID ) AS ORTALAMA
FROM POSITION PO WHERE PO.POSITION='PLANLAMA �EF�'
-----------------------------------------------------------------------------------------------------------------------------------------
--Her bir pozisyonda mevcut halde �al��anlar olarak ka� ki�i ve ortalama maa�lar�n�n ne kadar oldu�unu listeleme
SELECT PO.POSITION,COUNT(P.ID),AVG(SALARY) FROM PERSON P INNER JOIN POSITION PO
ON P.POSITIONID= PO.ID WHERE P.OUTDATE IS NOT NULL GROUP BY PO.POSITION; 
-----------------------------------------------------------------------------------------------------------------------------------------
--Y�llara g�re i�e al�nan personel say�s�n� kad�n ve erkek baz�nda listeleme
 SELECT YEAR(P1.INDATE),P1.GENDER,COUNT(P1.INDATE) FROM PERSON P1  GROUP BY YEAR(P1.INDATE),P1.GENDER ORDER BY YEAR(P1.INDATE)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Her bir personelimizin ne kadar zamand�r �al��t�g� bilgisini ay olarak getirme. personelad�, giri�, c�k��, ay
SELECT NAME_,INDATE,OUTDATE,
 CASE WHEN OUTDATE IS NULL THEN DATEDIFF(MONTH,INDATE,GETDATE()) 
      WHEN OUTDATE IS NOT NULL THEN DATEDIFF(MONTH,INDATE,OUTDATE) 
 END AS �ALI�MA_FARK�_AY FROM PERSON
 --OR
 SELECT NAME_, INDATE,OUTDATE, DATEDIFF(MONTH, INDATE,GETDATE()) AS �ALI�MA_FARK�_AY FROM PERSON WHERE OUTDATE IS NULL
 UNION ALL
 SELECT NAME_, INDATE, OUTDATE, DATEDIFF(MONTH, INDATE, OUTDATE) AS �ALI�MA_FARK�_AY FROM PERSON WHERE OUTDATE IS NOT NULL;
-----------------------------------------------------------------------------------------------------------------------------------------
--�irketimiz 5.y�l�nda �st�nde herkesin isminin ve soyisminin ba�harfleri bulundu�u bir ajanda bast�r�p �al��anlara hediye edilecektir.
--Bunun i�in hangi harf kombinasyonundan en az ne kadar say�da ajanda bast�r�lacag�sorusunun cevab�n� getiren sorgu.
-- Not iki isimli olanlar�n birinci isminin ba� harfi kullan�lacakt�r.
SELECT NAME_,SURNAME,CONCAT(LEFT(NAME_,1),'.',LEFT(SURNAME,1)),SUBSTRING(NAME_,1,1)+ '.'+ SUBSTRING(SURNAME,1,1),
DATEDIFF(YEAR, INDATE, GETDATE()) AS YIL  
FROM PERSON WHERE OUTDATE IS NULL AND DATEDIFF(YEAR, INDATE, GETDATE())> 5 
-----------------------------------------------------------------------------------------------------------------------------------------
--Maa� ortalamas� 5.500 tl'den fazla olan departmanlar� listeleyerek sorgulay�n�z.
SELECT D.DEPARTMENT, ROUND(AVG(P.SALARY),0) FROM PERSON P INNER JOIN DEPARTMENT D
ON P.DEPARTMENTID= D.ID  GROUP BY D.DEPARTMENT HAVING AVG(P.SALARY)>5500

--or 
SELECT *FROM
(SELECT D.DEPARTMENT, ROUND(AVG(P.SALARY),0) AS AVGSALARY FROM PERSON P INNER JOIN DEPARTMENT D
ON P.DEPARTMENTID= D.ID  GROUP BY D.DEPARTMENT) T 
WHERE AVGSALARY>5500
-----------------------------------------------------------------------------------------------------------------------------------------
--Departmanlar�n ortalama k�demini ay olarak hesaplama
SELECT DEPARTMENT,AVG(ORTALAMA_�ALI�MA) FROM 
(SELECT D.DEPARTMENT,
CASE WHEN P.OUTDATE IS NULL THEN DATEDIFF(MONTH, P.INDATE,GETDATE())
	 WHEN P.OUTDATE IS NOT NULL THEN DATEDIFF(MONTH,P.INDATE,P.OUTDATE)
 END AS ORTALAMA_�ALI�MA FROM PERSON P INNER JOIN DEPARTMENT D
ON P.DEPARTMENTID= D.ID ) T GROUP BY DEPARTMENT
  
-----------------------------------------------------------------------------------------------------------------------------------------
--Her personelin ad�n�, pozisyonunu ba�l� oldu�u birim y�neticisinin ad�n� ve pozisyonunu getiren sorgu

SELECT P.NAME_+ ' '+ P.SURNAME AS PERSONEL, POS.POSITION, PER.NAME_ + ' '+ PER.SURNAME AS Y�NET�C�S�, POS2.POSITION AS YONET�C�_POZ�SYON FROM PERSON P 
INNER JOIN POSITION POS ON  P.POSITIONID= POS.ID 
LEFT JOIN PERSON PER ON P.MANAGERID=PER.ID 
LEFT JOIN POSITION POS2 ON PER.POSITIONID =POS2.ID
WHERE P.NAME_+ ' '+ P.SURNAME IN ('An�l H��DURMAZ','�ule �ZVEZ','Kardelen BALIK�I','Huriye FERAH')
---------------------------------------------------------------------------------------------------------------------------------------