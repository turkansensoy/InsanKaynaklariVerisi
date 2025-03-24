use HR;
SELECT  *FROM PERSON
-----------------------------------------------------------------------------------------------------------------------------------------
-- Þirketimizde halen çalýþmaya devam eden çalýþanlarýn listesini getiren sorgu?
SELECT *FROM PERSON WHERE OUTDATE IS NULL;
-----------------------------------------------------------------------------------------------------------------------------------------
-- Þirketimizde departman bazlý halen çalýþmaya devam eden KADIN ve ERKEK sayýlarýný getirme.
SELECT D.DEPARTMENT,
 CASE
  WHEN P.GENDER='K' THEN 'KADIN'
  WHEN P.GENDER='E' THEN 'ERKEK'
 END AS GENDER, COUNT(P.ID) FROM PERSON P 
INNER JOIN DEPARTMENT D ON P.DEPARTMENTID=D.ID WHERE P.OUTDATE IS NULL GROUP BY D.DEPARTMENT, P.GENDER ORDER BY D.DEPARTMENT
-----------------------------------------------------------------------------------------------------------------------------------------
-- Þirketimizde departman bazlý halen çalýþmaya devam eden KADIN ve ERKEK sayýlarýný getirme Ayrý ayrý getirme.
SELECT *,(SELECT COUNT(*) FROM PERSON WHERE GENDER='K' AND DEPARTMENTID=D.ID AND OUTDATE IS NULL) AS KADINSAYISI,
    (SELECT COUNT(*) FROM PERSON WHERE GENDER='E'AND DEPARTMENTID=D.ID AND OUTDATE IS NULL) AS ERKEK_SAYISI,
    (SELECT COUNT(*) FROM PERSON WHERE DEPARTMENTID=D.ID AND OUTDATE IS NULL) AS TÜM_DURUM
	FROM DEPARTMENT D
-----------------------------------------------------------------------------------------------------------------------------------------
--Þirketimizin Planlama departmanýna yeni bir þef atamasý yapýldý ve maaþýný belirlemek istiyoruz.
--Planlama departmaný için minimum, maximum ve ortalama þef maaþý getiren sorgu
-- NOT Ýþten çýkmýþ olan personel maaþlarý da dahil.
SELECT PO.POSITION,MIN(SALARY) AS MÝN, MAX(SALARY) AS MAX, ROUND(AVG(SALARY),0) AS ORTALAMA FROM PERSON P INNER JOIN POSITION PO
ON P.POSITIONID=PO.ID WHERE PO.POSITION= 'PLANLAMA ÞEFÝ' GROUP BY PO.POSITION 
--OR
SELECT PO.POSITION,
(SELECT MIN(SALARY) FROM PERSON WHERE POSITIONID=PO.ID ) AS MINÝ,
(SELECT MAX(SALARY) FROM PERSON WHERE POSITIONID=PO.ID ) AS MAXÝ,
(SELECT ROUND(AVG(SALARY),0) FROM PERSON WHERE POSITIONID=PO.ID ) AS ORTALAMA
FROM POSITION PO WHERE PO.POSITION='PLANLAMA ÞEFÝ'
-----------------------------------------------------------------------------------------------------------------------------------------
--Her bir pozisyonda mevcut halde çalýþanlar olarak kaç kiþi ve ortalama maaþlarýnýn ne kadar olduðunu listeleme
SELECT PO.POSITION,COUNT(P.ID),AVG(SALARY) FROM PERSON P INNER JOIN POSITION PO
ON P.POSITIONID= PO.ID WHERE P.OUTDATE IS NOT NULL GROUP BY PO.POSITION; 
-----------------------------------------------------------------------------------------------------------------------------------------
--Yýllara göre iþe alýnan personel sayýsýný kadýn ve erkek bazýnda listeleme
 SELECT YEAR(P1.INDATE),P1.GENDER,COUNT(P1.INDATE) FROM PERSON P1  GROUP BY YEAR(P1.INDATE),P1.GENDER ORDER BY YEAR(P1.INDATE)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Her bir personelimizin ne kadar zamandýr çalýþtýgý bilgisini ay olarak getirme. personeladý, giriþ, cýkýþ, ay
SELECT NAME_,INDATE,OUTDATE,
 CASE WHEN OUTDATE IS NULL THEN DATEDIFF(MONTH,INDATE,GETDATE()) 
      WHEN OUTDATE IS NOT NULL THEN DATEDIFF(MONTH,INDATE,OUTDATE) 
 END AS ÇALIÞMA_FARKÝ_AY FROM PERSON
 --OR
 SELECT NAME_, INDATE,OUTDATE, DATEDIFF(MONTH, INDATE,GETDATE()) AS ÇALIÞMA_FARKÝ_AY FROM PERSON WHERE OUTDATE IS NULL
 UNION ALL
 SELECT NAME_, INDATE, OUTDATE, DATEDIFF(MONTH, INDATE, OUTDATE) AS ÇALIÞMA_FARKÝ_AY FROM PERSON WHERE OUTDATE IS NOT NULL;
-----------------------------------------------------------------------------------------------------------------------------------------
--Þirketimiz 5.yýlýnda üstünde herkesin isminin ve soyisminin baþharfleri bulunduðu bir ajanda bastýrýp çalýþanlara hediye edilecektir.
--Bunun için hangi harf kombinasyonundan en az ne kadar sayýda ajanda bastýrýlacagýsorusunun cevabýný getiren sorgu.
-- Not iki isimli olanlarýn birinci isminin baþ harfi kullanýlacaktýr.
SELECT NAME_,SURNAME,CONCAT(LEFT(NAME_,1),'.',LEFT(SURNAME,1)),SUBSTRING(NAME_,1,1)+ '.'+ SUBSTRING(SURNAME,1,1),
DATEDIFF(YEAR, INDATE, GETDATE()) AS YIL  
FROM PERSON WHERE OUTDATE IS NULL AND DATEDIFF(YEAR, INDATE, GETDATE())> 5 
-----------------------------------------------------------------------------------------------------------------------------------------
--Maaþ ortalamasý 5.500 tl'den fazla olan departmanlarý listeleyerek sorgulayýnýz.
SELECT D.DEPARTMENT, ROUND(AVG(P.SALARY),0) FROM PERSON P INNER JOIN DEPARTMENT D
ON P.DEPARTMENTID= D.ID  GROUP BY D.DEPARTMENT HAVING AVG(P.SALARY)>5500

--or 
SELECT *FROM
(SELECT D.DEPARTMENT, ROUND(AVG(P.SALARY),0) AS AVGSALARY FROM PERSON P INNER JOIN DEPARTMENT D
ON P.DEPARTMENTID= D.ID  GROUP BY D.DEPARTMENT) T 
WHERE AVGSALARY>5500
-----------------------------------------------------------------------------------------------------------------------------------------
--Departmanlarýn ortalama kýdemini ay olarak hesaplama
SELECT DEPARTMENT,AVG(ORTALAMA_ÇALIÞMA) FROM 
(SELECT D.DEPARTMENT,
CASE WHEN P.OUTDATE IS NULL THEN DATEDIFF(MONTH, P.INDATE,GETDATE())
	 WHEN P.OUTDATE IS NOT NULL THEN DATEDIFF(MONTH,P.INDATE,P.OUTDATE)
 END AS ORTALAMA_ÇALIÞMA FROM PERSON P INNER JOIN DEPARTMENT D
ON P.DEPARTMENTID= D.ID ) T GROUP BY DEPARTMENT
  
-----------------------------------------------------------------------------------------------------------------------------------------
--Her personelin adýný, pozisyonunu baðlý olduðu birim yöneticisinin adýný ve pozisyonunu getiren sorgu

SELECT P.NAME_+ ' '+ P.SURNAME AS PERSONEL, POS.POSITION, PER.NAME_ + ' '+ PER.SURNAME AS YÖNETÝCÝSÝ, POS2.POSITION AS YONETÝCÝ_POZÝSYON FROM PERSON P 
INNER JOIN POSITION POS ON  P.POSITIONID= POS.ID 
LEFT JOIN PERSON PER ON P.MANAGERID=PER.ID 
LEFT JOIN POSITION POS2 ON PER.POSITIONID =POS2.ID
WHERE P.NAME_+ ' '+ P.SURNAME IN ('Anýl HÝÇDURMAZ','Þule ÖZVEZ','Kardelen BALIKÇI','Huriye FERAH')
---------------------------------------------------------------------------------------------------------------------------------------