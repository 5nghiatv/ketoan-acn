-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Máy chủ: database:3306
-- Thời gian đã tạo: Th9 04, 2022 lúc 11:33 AM
-- Phiên bản máy phục vụ: 10.3.35-MariaDB-1:10.3.35+maria~focal
-- Phiên bản PHP: 8.0.21

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `ketoan_upload`
--

DELIMITER $$
--
-- Thủ tục
--
DROP PROCEDURE IF EXISTS `BoSungMahangPS`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `BoSungMahangPS` (IN `fromd` DATE, IN `tod` DATE)   BEGIN
    DECLARE cnam CHAR (4) DEFAULT concat(YEAR(tod),'');
    SET SESSION sql_mode = `NO_ENGINE_SUBSTITUTION`;
    INSERT INTO dmkhohag (nam,mahang,makho)
    SELECT CONCAT(YEAR(uz.ngay),'') AS nam ,u.mahang,u.makho from ctuktoan AS uz INNER JOIN ctuvattu AS u ON uz.ctid = u.ctid AND YEAR(uz.ngay) =YEAR(tod)AND
    (LEFT(uz.tkno,3) IN ('151','152','153','155','156','157','158','002','003')  OR LEFT(uz.tkco,3) IN ('151','152','153','155','156','157','158','002','003')) AND 
    CONCAT(YEAR(uz.ngay),u.mahang,u.makho) NOT IN (SELECT CONCAT(nam,mahang,makho) FROM dmkhohag)
    GROUP BY 1,2,3 ; 
END$$

DROP PROCEDURE IF EXISTS `BoSungTaiKhoanPS`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `BoSungTaiKhoanPS` (IN `fromd` DATE, IN `tod` DATE)   BEGIN
DECLARE cnam CHAR (4) DEFAULT concat(year(fromd),'');
SET SESSION sql_mode = `NO_ENGINE_SUBSTITUTION`;
INSERT INTO dmsodutk (nam,sotk,tkhoan)
    select CONCAT(YEAR(uc.ngay),'') AS nam ,tkno as sotk,matkno as tkhoan from ctuktoan AS uc WHERE YEAR(uc.ngay) =YEAR(tod) AND CONCAT(YEAR(uc.ngay),uc.tkno,uc.matkno) NOT IN (SELECT CONCAT(nam,sotk,tkhoan) FROM dmsodutk)
    UNION 
    select CONCAT(YEAR(uv.ngay),'') AS nam ,tkco as sotk,matkco as tkhoan from ctuktoan AS uv WHERE YEAR(uv.ngay) =YEAR(tod) AND CONCAT(YEAR(uv.ngay),uv.tkco,uv.matkco) NOT IN (SELECT CONCAT(nam,sotk,tkhoan) FROM dmsodutk)
    UNION 
    select CONCAT(YEAR(uz.ngay),'') AS nam ,u.tkno as sotk,u.matkno as tkhoan from chitiet AS u INNER JOIN ctuktoan AS uz ON u.ctid = uz.ctid AND YEAR(uz.ngay) =YEAR(tod) AND CONCAT(YEAR(uz.ngay),u.tkno,u.matkno) NOT IN (SELECT CONCAT(nam,sotk,tkhoan) FROM dmsodutk)
    UNION 
    select CONCAT(YEAR(ux.ngay),'') AS nam ,us.tkco as sotk,us.matkco as tkhoan from chitiet AS us INNER JOIN ctuktoan AS ux  ON us.ctid = ux.ctid AND YEAR(ux.ngay) =YEAR(tod) AND CONCAT(YEAR(ux.ngay),us.tkco,us.matkco) NOT IN (SELECT CONCAT(nam,sotk,tkhoan) FROM dmsodutk)
    GROUP BY 1,2,3 ; 
UPDATE dmsodutk as cd RIGHT JOIN dmtkhoan as dm ON cd.sotk = dm.sotk SET cd.tentk = dm.tentk WHERE cd.nam=cnam AND TRIM(cd.tkhoan) = '';
UPDATE dmsodutk as cd RIGHT JOIN tenmuc as dm ON cd.tkhoan = dm.tkhoan SET cd.tentk = dm.tenkhoan WHERE cd.nam=cnam AND TRIM(cd.tkhoan) <> '' ;
END$$

DROP PROCEDURE IF EXISTS `ChuyenSoDuHangHoa`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ChuyenSoDuHangHoa` (IN `fromd` DATE, IN `tod` DATE, IN `nlan` TINYINT(1))   BEGIN
DECLARE cnam CHAR (4) DEFAULT concat(year(fromd),'');
DECLARE cnamt CHAR (4) DEFAULT concat(year(fromd)-1,'');
DECLARE fromdt DATE DEFAULT MAKEDATE(YEAR(tod)-1,1);
DECLARE todt DATE DEFAULT DATE(DATE_SUB(MAKEDATE(YEAR(tod),1), INTERVAL 24 HOUR)) ;
IF nlan=0 OR nlan=1 THEN
    INSERT INTO dmkhohag (nam,mahang,makho) 
    (SELECT cnam as nam ,u.mahang,u.makho from dmkhohag AS u where u.nam=cnamt AND concat(u.mahang,u.makho) not in ( select concat(us.mahang,us.makho) from dmkhohag AS us  where us.nam=cnam)) ;
END IF;
IF nlan=0 OR nlan=1 THEN
    UPDATE dmkhohag uz INNER JOIN  
    (SELECT cnam as nam,u.mahang,u.makho,u.luongck,u.tienck from dmkhohag AS u where u.nam=cnamt ) AS us ON CONCAT(uz.nam,uz.mahang,uz.makho)= CONCAT(us.nam,us.mahang,us.makho) AND uz.nam = cnam
    SET uz.luongdn =us.luongck ,uz.tiendn = us.tienck ;
END IF;
END$$

DROP PROCEDURE IF EXISTS `ChuyenSoDuTaiKhoan`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ChuyenSoDuTaiKhoan` (IN `fromd` DATE, IN `tod` DATE, IN `nlan` TINYINT(1))   BEGIN
DECLARE cnam CHAR (4) DEFAULT concat(year(fromd),'');
DECLARE cnamt CHAR (4) DEFAULT concat(year(fromd)-1,'');
DECLARE fromdt DATE DEFAULT MAKEDATE(YEAR(tod)-1,1);
DECLARE todt DATE DEFAULT DATE(DATE_SUB(MAKEDATE(YEAR(tod),1), INTERVAL 24 HOUR)) ;
IF nlan=0 OR nlan=1 THEN
    INSERT INTO dmsodutk (nam,sotk,tkhoan) 
    (SELECT cnam as nam ,u.sotk,u.tkhoan from dmsodutk AS u where u.nam=cnamt AND concat(u.sotk,u.tkhoan) not in ( select concat(us.sotk,us.tkhoan) from dmsodutk AS us  where us.nam=cnam)) ;
END IF;
IF nlan=0 OR nlan=2 THEN
    UPDATE dmsodutk uz INNER JOIN  
    (SELECT cnam as nam,u.sotk,u.tkhoan,u.nock,u.cock from dmsodutk AS u where u.nam=cnamt ) AS us ON CONCAT(uz.nam,uz.sotk,uz.tkhoan)= CONCAT(us.nam,us.sotk,us.tkhoan) AND uz.nam = cnam
    SET uz.nodn =us.nock ,uz.codn = us.cock ;
END IF;
END$$

DROP PROCEDURE IF EXISTS `CopyChungtuID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CopyChungtuID` (IN `cCtid` VARCHAR(12), IN `newd` DATE)   BEGIN
DECLARE newCtid CHAR (12) DEFAULT "";
SELECT GetNextCtid() INTO newCtid;
INSERT INTO ctuktoan (
  `id`,`ctid`, `soct`, `ngay`, `diengiai`, `tkno` ,
  `matkno` , `tkco` , `matkco` , `sotien` , `ngaytt` ,
  `hopdong` , `nhom` , `loaitien` , `ngoaite` , `userid` ,
  `ghichu` , `khac` , `sodk` , `mamauhd` , `ngaytra` )
SELECT NULL, newCtid as ctid , `soct`, newd , CONCAT('_COPY_',`diengiai`) as `diengiai`, `tkno` ,`matkno` , `tkco` , `matkco` , `sotien` , `ngaytt` , `hopdong` , `nhom` , `loaitien` , `ngoaite` , `userid` ,
  `ghichu` , `khac` , `sodk` , `mamauhd` , `ngaytra` FROM ctuktoan WHERE ctid = cCtid;

INSERT INTO ctuvattu (
  `id` ,`ctid` ,`mahang` ,`makho` ,`soluong` ,`dongia` ,
  `sotien` ,`vtkhac` ,`ngoaite` ,`doituong` ,`giaban` ,
  `thue` ,`soluong2` ,`doituong2` )
SELECT NULL,newCtid as ctid ,`mahang` ,`makho` ,`soluong` ,`dongia` ,`sotien` ,`vtkhac` ,`ngoaite` ,`doituong` ,`giaban` ,`thue` ,`soluong2` ,`doituong2` FROM ctuvattu WHERE ctid = cCtid;

INSERT INTO chitiet (
  `id` ,`ctid` ,`diengiai`,`tkno` ,`matkno` ,
  `tkco` ,`matkco` ,`sotien` ,`ngoaite` ,`ctkhac`) 
SELECT NULL,newCtid as ctid ,`diengiai`,`tkno` ,`matkno` ,
  `tkco` ,`matkco` ,`sotien` ,`ngoaite` ,`ctkhac` FROM chitiet WHERE ctid = cCtid;

INSERT INTO hoadon (
  `id` ,`ctid` ,`mausohd` ,`sohd` ,`ngay` ,`diengiai` ,
  `thuesuat` ,`giaban` ,`thuegtgt` ,`mamauhd` ,`sohdong` ,
  `ngayhdong` ,`hinhthuctt` ,`diemgiao` ,`diemnhan` ,
  `sovandon` ,`socontaine` ,`dvanchuyen` ,`dienthoai` ,
  `tygia` ,`masothue` ) 
SELECT NULL,newCtid as ctid ,`mausohd` ,`sohd` ,`ngay` ,`diengiai` , `thuesuat` ,`giaban` ,`thuegtgt` ,`mamauhd` ,`sohdong` , `ngayhdong` ,`hinhthuctt` ,`diemgiao` ,`diemnhan` , `sovandon` ,`socontaine` ,`dvanchuyen` ,`dienthoai` , `tygia` ,`masothue`  FROM hoadon WHERE ctid = cCtid;

SELECT * ,count(*) as count FROM `ctuktoan` WHERE ctid = newCtid;

END$$

DROP PROCEDURE IF EXISTS `CopyChungtuKt`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CopyChungtuKt` (IN `fromd` DATE, IN `tod` DATE, IN `newd` DATE)   BEGIN
	DECLARE finished INTEGER DEFAULT 0;
	DECLARE listFld varchar(100) DEFAULT "";

	-- declare cursor for employee email
	DEClARE curList
		CURSOR FOR 
			SELECT ctid FROM ctuktoan WHERE ngay BETWEEN fromd AND tod ;

	-- declare NOT FOUND handler
	DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

	OPEN curList;

	getList: LOOP
		FETCH curList INTO listFld;
		IF finished = 1 THEN 
			LEAVE getList;
		END IF;
		-- build email list
		-- SET ListID = CONCAT(listFld,";",ListID);
        CALL CopyChungtuID(listFld, newd);
	END LOOP getList;
	CLOSE curList;

END$$

DROP PROCEDURE IF EXISTS `CreateDanhMucToiThieu`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateDanhMucToiThieu` ()   BEGIN
DECLARE cmaso CHAR (3) DEFAULT '001' ;
INSERT INTO dmtiente (loaitien,tengoi,viettat)
SELECT * FROM (SELECT cmaso as loaitien , 'Tiền Việt Nam', 'VND') AS tmp WHERE NOT EXISTS (SELECT loaitien FROM dmtiente WHERE loaitien = cmaso) LIMIT 1 ;
INSERT INTO dmtenkho (makho,tengoi,diachi)
SELECT * FROM (SELECT cmaso as makho, 'Kho Công ty', '118/63 Bạch Đằng, P24, Q.Bình Thanh -HCM') AS tmp
WHERE NOT EXISTS (SELECT makho FROM dmtenkho WHERE makho = cmaso) LIMIT 1 ;
INSERT INTO tenmuc (tkhoan)
SELECT * FROM (SELECT '') AS tmp
WHERE NOT EXISTS (SELECT tkhoan FROM tenmuc WHERE tkhoan = '') LIMIT 1 ;
select 'Check OK';
END$$

DROP PROCEDURE IF EXISTS `CreateView_Ctuktoan`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateView_Ctuktoan` ()   BEGIN
DROP VIEW IF EXISTS ctuktoanview;
CREATE VIEW ctuktoanview AS SELECT kt.soct, kt.ngay, IFNULL(ct.diengiai,kt.diengiai) AS diengiai, IFNULL(ct.tkno,kt.tkno) AS tkno, IFNULL(ct.tkco,kt.tkco) AS tkco, IFNULL(ct.sotien,kt.sotien) AS sotien, IFNULL(ct.ngoaite,kt.ngoaite) AS ngoaite FROM ctuktoan as kt LEFT OUTER JOIN chitiet as ct ON  kt.ctid = ct.ctid ;
END$$

DROP PROCEDURE IF EXISTS `CreateView_Ctuvattu`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateView_Ctuvattu` ()   BEGIN
DROP VIEW IF EXISTS ctuvattuview;
CREATE VIEW ctuvattuview AS SELECT kt.soct, kt.ngay,kt.tkno,kt.tkco, vt.mahang, vt.makho ,th.tenhang,th.donvi,vt.soluong,vt.sotien,vt.ngoaite FROM ctuktoan as kt RIGHT OUTER JOIN ctuvattu as vt ON kt.ctid = vt.ctid LEFT OUTER JOIN tenhang as th ON vt.mahang = th.mahang where (LEFT(kt.tkno,3) IN ('151','152','153','155','156','157','158','002','003') or LEFT(kt.tkco,3) IN ('151','152','153','155','156','157','158','002','003'));
END$$

DROP PROCEDURE IF EXISTS `Create_Ctuketoan`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Create_Ctuketoan` (IN `fromd` DATE, IN `tod` DATE)   BEGIN
SELECT kt.ctid,kt.soct, kt.ngay, kt.sotien as sotienkt,"" as sotienvn, kt.tkno as tknokt, kt.tkco as tkcokt, IFNULL(ct.diengiai,kt.diengiai) AS diengiai, IFNULL(ct.tkno,kt.tkno) AS tkno,IFNULL(ct.matkno,kt.matkno) AS matkno, IFNULL(ct.tkco,kt.tkco) AS tkco,IFNULL(ct.matkco,kt.matkco) AS matkco, IFNULL(ct.sotien,kt.sotien) AS sotien, IFNULL(ct.ngoaite,kt.ngoaite) AS ngoaite,kt.ctid,kt.ghichu FROM ctuktoan as kt LEFT OUTER JOIN chitiet as ct ON  kt.ctid = ct.ctid where kt.ngay BETWEEN fromd AND tod ;
END$$

DROP PROCEDURE IF EXISTS `Create_Ctuketoan2`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Create_Ctuketoan2` (IN `fromd` DATE, IN `tod` DATE, IN `ctid` VARCHAR(15))   BEGIN
SELECT kt.id,kt.ctid,kt.soct, kt.ngay, kt.sotien as sotienkt,"" as sotienvn, kt.tkno as tknokt, kt.tkco as tkcokt, IFNULL(ct.diengiai,kt.diengiai) AS diengiai, IFNULL(ct.tkno,kt.tkno) AS tkno,IFNULL(ct.matkno,kt.matkno) AS matkno, IFNULL(ct.tkco,kt.tkco) AS tkco,IFNULL(ct.matkco,kt.matkco) AS matkco, IFNULL(ct.sotien,kt.sotien) AS sotien, IFNULL(ct.ngoaite,kt.ngoaite) AS ngoaite,kt.ctid,kt.ghichu FROM ctuktoan as kt LEFT OUTER JOIN chitiet as ct ON  kt.ctid = ct.ctid where IF(ctid, kt.ngay BETWEEN fromd AND tod AND kt.ctid = ctid ,kt.ngay BETWEEN fromd AND tod ) ORDER BY CONCAT(ngay, soct);
END$$

DROP PROCEDURE IF EXISTS `Create_Ctuketoan_Rg`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Create_Ctuketoan_Rg` (IN `fromd` DATE, IN `tod` DATE)   BEGIN
SELECT kt.ngay, IFNULL(ct.tkno,kt.tkno) AS tkno,IFNULL(ct.matkno,kt.matkno) AS matkno, IFNULL(ct.tkco,kt.tkco) AS tkco,IFNULL(ct.matkco,kt.matkco) AS matkco, SUM(IFNULL(ct.sotien,kt.sotien)) AS sotien, SUM(IFNULL(ct.ngoaite,kt.ngoaite)) AS ngoaite FROM ctuktoan as kt LEFT OUTER JOIN chitiet as ct ON  kt.ctid = ct.ctid where kt.ngay BETWEEN fromd AND tod GROUP BY 1,2,3,4,5;
END$$

DROP PROCEDURE IF EXISTS `Create_Ctuvattu`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Create_Ctuvattu` (IN `fromd` DATE, IN `tod` DATE)   BEGIN
SELECT kt.ctid,kt.soct, kt.ngay,kt.diengiai,kt.tkno, kt.tkco,kt.sotien as sotienkt,"" as sotienvn, vt.mahang, vt.makho ,th.tenhang,th.donvi,vt.soluong,vt.sotien FROM ctuktoan as kt RIGHT OUTER JOIN ctuvattu as vt ON  kt.ctid = vt.ctid LEFT OUTER JOIN tenhang as th ON  vt.mahang = th.mahang where kt.ngay BETWEEN fromd AND tod AND (LEFT(kt.tkno,3) IN ('151','152','153','155','156','157','158','002','003') or LEFT(kt.tkco,3) IN ('151','152','153','155','156','157','158','002','003')) 
;
END$$

DROP PROCEDURE IF EXISTS `Create_Ctuvattu2`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Create_Ctuvattu2` (IN `fromd` DATE, IN `tod` DATE, IN `ctid` VARCHAR(15))   BEGIN
SELECT kt.ctid,kt.soct, kt.ngay,kt.diengiai,kt.tkno, kt.tkco,kt.sotien as sotienkt,"" as sotienvn, vt.mahang, vt.makho ,th.tenhang,th.donvi,vt.soluong,vt.sotien ,kh.tengoi,kh.diachi FROM ctuktoan as kt RIGHT OUTER JOIN ctuvattu as vt ON  kt.ctid = vt.ctid LEFT OUTER JOIN tenhang as th ON  vt.mahang = th.mahang LEFT OUTER JOIN dmtenkho as kh ON  vt.makho = kh.makho where IF(ctid, kt.ngay BETWEEN fromd AND tod AND kt.ctid = ctid ,kt.ngay BETWEEN fromd AND tod ) AND (LEFT(kt.tkno,3) IN ('151','152','153','155','156','157','158','002','003') or LEFT(kt.tkco,3) IN ('151','152','153','155','156','157','158','002','003')) 
 ORDER BY CONCAT(ngay, soct);
END$$

DROP PROCEDURE IF EXISTS `Create_CtuvattuHoadon`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Create_CtuvattuHoadon` (IN `fromd` DATE, IN `tod` DATE, IN `ctid` VARCHAR(15))   BEGIN
SELECT kt.ctid,kt.soct, kt.ngay,kt.diengiai,kt.tkno, kt.tkco,kt.sotien as sotienkt,"" as sotienvn, vt.mahang, vt.makho ,th.tenhang,th.donvi,vt.soluong,vt.sotien ,kh.tengoi,kh.diachi,COUNT('hd.ctid') as demHoadon FROM ctuktoan as kt LEFT OUTER JOIN ctuvattu as vt ON  kt.ctid = vt.ctid RIGHT OUTER JOIN tenhang as th ON  vt.mahang = th.mahang RIGHT OUTER JOIN dmtenkho as kh ON  vt.makho = kh.makho RIGHT OUTER JOIN hoadon as hd ON  kt.ctid = hd.ctid where IF(ctid, kt.ngay BETWEEN fromd AND tod AND kt.ctid = ctid ,kt.ngay BETWEEN fromd AND tod ) AND LEFT(kt.tkco,3)="511" GROUP BY kt.ctid,vt.mahang ;
END$$

DROP PROCEDURE IF EXISTS `Create_MathangBan`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Create_MathangBan` (IN `fromd` DATE, IN `tod` DATE, IN `ctid` VARCHAR(15))   BEGIN
SELECT kt.ctid,kt.soct, kt.ngay,kt.diengiai,kt.tkno, kt.tkco,kt.sotien as sotienkt,"" as sotienvn, vt.mahang, vt.makho ,th.tenhang,th.donvi,vt.soluong,vt.sotien ,kh.tengoi,kh.diachi FROM ctuktoan as kt RIGHT OUTER JOIN ctuvattu as vt ON  kt.ctid = vt.ctid LEFT OUTER JOIN tenhang as th ON  vt.mahang = th.mahang LEFT OUTER JOIN dmtenkho as kh ON  vt.makho = kh.makho where IF(ctid, kt.ngay BETWEEN fromd AND tod AND kt.ctid = ctid ,kt.ngay BETWEEN fromd AND tod ) AND LEFT(kt.tkco,3) ='511' 
 ORDER BY CONCAT(ngay, soct);
END$$

DROP PROCEDURE IF EXISTS `DelAllTables`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DelAllTables` (IN `dbname` VARCHAR(20))   BEGIN
    SET FOREIGN_KEY_CHECKS = 0; 
    SET @tables = NULL;
    SET @dbname = dbname;
    SELECT GROUP_CONCAT('`', table_schema, '`.`', table_name, '`') INTO @tables
      FROM information_schema.tables 
      WHERE table_schema =  @dbname;

    SET @tables = CONCAT('DROP TABLE ', @tables);
    PREPARE stmt FROM @tables;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET FOREIGN_KEY_CHECKS = 1; 

END$$

DROP PROCEDURE IF EXISTS `DelAndAlterTableCtid`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DelAndAlterTableCtid` ()   BEGIN
	
	DROP TABLE IF EXISTS `categories`,`companies`,`ctutensp`,`dmkygui`,`customers`,`dulieu`,`giathanh`,`ibc_dss`,`khauhao`,`dmtaisan`,`dmtensp`,`gtrinhqt`,`ngaytran`,`migrations`,`nhanvien`,`noidatts`,`password_resets`,
 `phanbo`,`posts`,`products`,`products_attributes`,`repolist`,`sanpham`,`sessions`,`settings`,`social_accounts`,`spdauky`,
 `tasks`,`dmkhohg2`,`tennhom`,`tkhoan`,`tygia`,`articles`;
	
    DELETE FROM quanlykt WHERE tentaptin="CTUKTOAN";
	SET foreign_key_checks = 0;
    
  SET @ddl = CONCAT(' alter table ', 'chitiet'  ,' CHANGE ', 'ctid', ' ', 'ctid', ' CHAR(12) NOT NULL');
  PREPARE STMT FROM @ddl;
  EXECUTE STMT;
  
	SET @ddl = CONCAT(' alter table ', 'ctuvattu'  ,' CHANGE ', 'ctid', ' ', 'ctid', ' CHAR(12) NOT NULL');
  PREPARE STMT FROM @ddl;
  EXECUTE STMT;  
  
	SET @ddl = CONCAT(' alter table ', 'hoadon'  ,' CHANGE ', 'ctid', ' ', 'ctid', ' CHAR(12) NOT NULL');
  PREPARE STMT FROM @ddl;
  EXECUTE STMT;
  
	SET @ddl = CONCAT(' alter table ', 'ctuktoan'  ,' CHANGE ', 'ctid', ' ', 'ctid', ' CHAR(12) NOT NULL');
  PREPARE STMT FROM @ddl;
  EXECUTE STMT;    

	SET @ddl = CONCAT(' alter table ', 'quanlykt'  ,' CHANGE ', 'numid', ' ', 'numid', ' CHAR(12) NOT NULL');
  PREPARE STMT FROM @ddl;
  EXECUTE STMT;    
END$$

DROP PROCEDURE IF EXISTS `DelChungtuID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DelChungtuID` (IN `cCtid` VARCHAR(10))   BEGIN

DELETE FROM hoadon WHERE ctid = cCtid;
DELETE FROM ctuvattu WHERE ctid = cCtid;
DELETE FROM chitiet WHERE ctid = cCtid;    
DELETE FROM ctuktoan WHERE ctid = cCtid;
SELECT cCtid as ctid ,count(*) as count FROM `ctuktoan` WHERE ctid = cCtid;

END$$

DROP PROCEDURE IF EXISTS `DelChungtuNam`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DelChungtuNam` (IN `fromdate` DATE)   BEGIN
	DECLARE cnam CHAR (4) DEFAULT concat(year(fromdate),'');
    DECLARE fromd DATE DEFAULT MAKEDATE(YEAR(fromdate),1);
    DECLARE tod DATE DEFAULT DATE(concat(year(fromdate),'-12-31') );
    
    DELETE FROM hoadon WHERE ctid IN (SELECT ctid FROM ctuktoan WHERE ngay BETWEEN fromd AND tod);
    DELETE FROM chitiet WHERE ctid IN (SELECT ctid FROM ctuktoan WHERE ngay BETWEEN fromd AND tod);
    DELETE FROM ctuvattu WHERE ctid IN (SELECT ctid FROM ctuktoan WHERE ngay BETWEEN fromd AND tod);
    DELETE FROM ctuktoan WHERE ngay BETWEEN fromd AND tod;
	
    SELECT concat('SUCCESSFULLY DELETE FROM ',fromd,' - ', tod) as REPORT  ;
END$$

DROP PROCEDURE IF EXISTS `GanTienHangHoadon`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GanTienHangHoadon` (IN `cCtid` VARCHAR(15), IN `nSotien` DECIMAL(15), IN `nThue` DECIMAL(15), IN `tkThue` VARCHAR(15))   BEGIN
-- SELECT cCtid,nSotien,nThue,tkThue ;
DECLARE nid INT(12) DEFAULT 0;
DECLARE nid2 INT(12) DEFAULT 0;
DECLARE zchitiet INT(12) DEFAULT 0;

-- 1.Replace Tong tien <-- Vat tu hoac Chi tiet
SELECT id FROM chitiet WHERE ctid = cCtid AND tkno+tkco IN (SELECT tkno+tkco FROM ctuktoan WHERE ctid = cCtid) LIMIT 1 INTO nid; 
IF nid <> 0 THEN
-- Nếu số Chi tiết > 2 thì gán hết = 0 ,sau đó chỉ gán 1
	UPDATE chitiet SET sotien = 0 WHERE ctid = cCtid AND tkno+tkco IN (SELECT tkno+tkco FROM ctuktoan WHERE ctid = cCtid);
	UPDATE chitiet SET sotien = nSotien WHERE id = nid;
ELSE
	INSERT INTO chitiet (`id` ,`ctid`,`diengiai`,`tkno` ,`matkno` ,
  `tkco` ,`matkco` ,`sotien` ,`ngoaite`) 
  SELECT NULL,`ctid`,`diengiai`,`tkno` ,`matkno` ,
  `tkco` ,`matkco` ,nSotien as sotien ,`ngoaite` FROM ctuktoan WHERE ctid = cCtid;
    
END IF;

-- 1.Replace Tong tien <-- Thue VAT Dau VAO Hoac RA
IF tkThue <> "" THEN
	IF SUBSTRING(tkThue,1,4) = "1331" THEN
		SELECT id FROM chitiet WHERE ctid= cCtid AND tkno=tkThue AND tkco IN (SELECT tkco FROM ctuktoan WHERE ctid = cCtid) LIMIT 1 INTO nid2; 

	    IF nid2 <> 0 THEN
        	UPDATE chitiet SET sotien = 0  WHERE ctid= cCtid AND tkno=tkThue AND tkco IN (SELECT tkco FROM ctuktoan WHERE ctid = cCtid);
	        UPDATE chitiet SET sotien = nThue WHERE id = nid2;
	    ELSE
        	IF nThue <> "0" THEN
	        	INSERT INTO chitiet (`id` ,`ctid`,`diengiai`,`tkno` ,`matkno` ,
	      `tkco` ,`matkco` ,`sotien` ,`ngoaite`) 
	      SELECT NULL,cCtid as ctid,`diengiai`,tkThue ,`matkno` ,
	      `tkco` ,`matkco` ,nThue as sotien ,`ngoaite` FROM ctuktoan WHERE ctid = cCtid;
			END IF;
	    END IF;
	END IF;
	IF SUBSTRING(tkThue,1,4) = "3331" THEN
		SELECT id FROM chitiet WHERE ctid= cCtid AND tkco=tkThue AND tkno IN (SELECT tkno FROM ctuktoan WHERE ctid = cCtid) LIMIT 1 INTO nid2; 

	    IF nid2 <> 0 THEN
        	UPDATE chitiet SET sotien = 0  WHERE ctid= cCtid AND tkco=tkThue AND tkno IN (SELECT tkno FROM ctuktoan WHERE ctid = cCtid);
	        UPDATE chitiet SET sotien = nThue WHERE id = nid2;
	    ELSE
        	IF nThue <> "0" THEN
	        	INSERT INTO chitiet (`id` ,`ctid`,`diengiai`,`tkno` ,`matkno` ,
	      `tkco` ,`matkco` ,`sotien` ,`ngoaite`) 
	      SELECT NULL,cCtid as ctid,`diengiai`,tkno ,`matkno` ,
	      tkThue ,`matkco` ,nThue as sotien ,`ngoaite` FROM ctuktoan WHERE ctid = cCtid;
			END IF;
	    END IF;
	END IF;
    
END IF;

SELECT SUM(sotien) FROM chitiet WHERE ctid= cCtid INTO zchitiet;

UPDATE ctuktoan SET sotien = zchitiet WHERE ctid = cCtid;
SELECT * FROM chitiet WHERE ctid = cCtid;

END$$

DROP PROCEDURE IF EXISTS `getCountAllTables`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getCountAllTables` ()   BEGIN                                                                                                                                                                         DECLARE table_name VARCHAR(255);                                                                                                                                     DECLARE end_of_tables INT DEFAULT 0;                                                                                                                                 DECLARE cur CURSOR FOR                                                                                                                                                   SELECT t.table_name                                                                                                                                                   FROM information_schema.tables t                                                                                                                                     WHERE t.table_schema = DATABASE() AND t.table_type='BASE TABLE';                                                                                                 DECLARE CONTINUE HANDLER FOR NOT FOUND SET end_of_tables = 1;                                                                                                         OPEN cur;                                                                                                                                                             tables_loop: LOOP                                                                                                                                                         FETCH cur INTO table_name;                                                                                                                                           IF end_of_tables = 1 THEN                                                                                                                                                 LEAVE tables_loop;                                                                                                                                               END IF;                                                                                                                                                             
            SET @s = CONCAT('SELECT ''', table_name, ''', COUNT(*) AS Count FROM ' , table_name);                                                                                 PREPARE stmt FROM @s;                                                                                                                                                 EXECUTE stmt;                                                                                                                                                     END LOOP;                                                                                                                                                             CLOSE cur;                                                                                                                                                 END$$

DROP PROCEDURE IF EXISTS `getCtuktoan`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getCtuktoan` ()   BEGIN  
    DECLARE total INT; 
    ##Create variables to receive cursor data  
    DECLARE ctid VARCHAR(12);  
    #Create end flag variable  
    DECLARE done INT DEFAULT false;  
    #Create cursor  
    DECLARE cur CURSOR FOR SELECT ctid FROM ctuktoan WHERE ngay BETWEEN '2020-10-01' AND '2020-12-31';  
    #Specifies the return value at the end of the cursor loop  
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = true;   
    SET total = 0;  
    OPEN cur;  
    FETCH cur INTO ctid;  
    WHILE(NOT done) 
    DO  
        SET total = total + 1;  
        SELECT total,ctid;  

        FETCH cur INTO ctid;  
    END WHILE;  

    CLOSE cur;  
    SELECT total;  
END$$

DROP PROCEDURE IF EXISTS `getFieldsAllTables`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getFieldsAllTables` (IN `dataname` TEXT)  NO SQL BEGIN

SELECT TABLE_NAME , COLUMN_NAME FROM information_schema.columns WHERE table_schema = dataname ORDER BY table_name,ordinal_position;

END$$

DROP PROCEDURE IF EXISTS `getHoadon`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getHoadon` (IN `fromdate` DATE, IN `todate` DATE, IN `maso` VARCHAR(10), IN `sapxep` VARCHAR(10), IN `ctid` VARCHAR(15))  NO SQL SELECT  hoadon.id,hoadon.ctid,hoadon.sohd,hoadon.ngay,customer.company,customer.maso,customer.address, RIGHT(CONCAT("   ",TRIM(REPLACE(hoadon.thuesuat,"%",""))),3) as orderthues, hoadon.thuesuat ,hoadon.giaban as sotien,hoadon.thuegtgt,hoadon.giaban+hoadon.thuegtgt as congtienvn,customer.ghichu as mathang, hoadon.diengiai, customer.account,customer.bank,customer.citibank,customer.fullname,IFNULL(chitiet.tkno,ctuktoan.tkno) AS tkno, IFNULL(chitiet.tkco,ctuktoan.tkco) AS tkco,ctuktoan.soct,ctuktoan.ngay as ngayct from `hoadon` left join `ctuktoan` on `hoadon`.`ctid` = `ctuktoan`.`ctid` left join `customer` on `hoadon`.`masothue` = `customer`.`maso` left join `chitiet` on `chitiet`.`ctid` = `hoadon`.`ctid` where 
CASE 
WHEN maso= '20' THEN ((LEFT(IFNULL(chitiet.tkco,ctuktoan.tkco),4) !='3331') AND (LEFT(IFNULL(chitiet.tkco,ctuktoan.tkco),3) ='511') )
WHEN maso= '10' THEN (LEFT(IFNULL(chitiet.tkno,ctuktoan.tkno),4) !='1331') AND (LEFT(IFNULL(chitiet.tkco,ctuktoan.tkco),4) !='3331') AND (LEFT(IFNULL(chitiet.tkco,ctuktoan.tkco),3) !='511')
WHEN maso= '21' THEN (LEFT(IFNULL(chitiet.tkco,ctuktoan.tkco),4)='3331') 
WHEN maso= '11' THEN (LEFT(IFNULL(chitiet.tkno,ctuktoan.tkno),4)='1331')
ELSE (LEFT(IFNULL(chitiet.tkno,ctuktoan.tkno),4)='1331')
END 
and IF(ctid, `ctuktoan`.`ngay` between fromdate and todate AND `ctuktoan`.ctid = ctid ,`ctuktoan`.`ngay` between fromdate and todate ) GROUP BY 1 ORDER BY
CASE 
WHEN sapxep = 'ngay' THEN CONCAT(`hoadon`.`ngay`, `hoadon`.`sohd`)
WHEN sapxep = 'sohd' THEN CONCAT(`hoadon`.`sohd` , `ctuktoan`.`ngay`)
WHEN sapxep = 'thuesuat' THEN CONCAT(`orderthues` , `hoadon`.`sohd`)
ELSE `customer`.`maso`
END$$

DROP PROCEDURE IF EXISTS `GetNextCTID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetNextCTID` (IN `NextID` INT(14))   BEGIN
	-- LOCK TABLE quanlykt WRITE;
    -- DECLARE NextID INT DEFAULT 0;
	UPDATE quanlykt set numid=numid+1 where UPPER(tentaptin)='CTUKTOAN'; 
	SELECT numid INTO NextID FROM quanlykt where UPPER(tentaptin)='CTUKTOAN';
 	SELECT NextID;
    IF NextID IS null then 
     	SELECT MAX(ABS(ctid))+1 INTO NextID from ctuktoan;
        SELECT NextID ;
    	INSERT INTO quanlykt (tentaptin,numid ) VALUES ('CTUKTOAN', NextID);
    END IF;
    -- UNLOCK TABLES;
END$$

DROP PROCEDURE IF EXISTS `getRowsAllTables`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getRowsAllTables` ()   BEGIN
DECLARE table_name VARCHAR(255);
DECLARE end_of_tables INT DEFAULT 0;
DECLARE cur CURSOR FOR SELECT t.table_name FROM information_schema.tables t  WHERE t.table_schema = DATABASE() AND t.table_type='BASE TABLE';
DECLARE CONTINUE HANDLER FOR NOT FOUND SET end_of_tables = 1;
OPEN cur;

tables_loop: LOOP
FETCH cur INTO table_name;
IF end_of_tables = 1 THEN
	LEAVE tables_loop;
END IF;
SET @s = CONCAT('SELECT ''', table_name, ''' as table_name,',  table_name,'.* FROM ' , table_name);
PREPARE stmt FROM @s;
EXECUTE stmt;
END LOOP;
CLOSE cur;
END$$

DROP PROCEDURE IF EXISTS `getShowCreateAllProcs`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getShowCreateAllProcs` (IN `func_pro` VARCHAR(250))   BEGIN
DECLARE table_name VARCHAR(255);
DECLARE end_of_tables INT DEFAULT 0;
DECLARE cur CURSOR FOR SELECT ROUTINE_NAME as table_name FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = database() AND ROUTINE_TYPE = func_pro;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET end_of_tables = 1;
OPEN cur;

tables_loop: LOOP
FETCH cur INTO table_name;
IF end_of_tables = 1 THEN
	LEAVE tables_loop;
END IF;
SET @s = CONCAT('SHOW CREATE ',func_pro,' ' , table_name);
PREPARE stmt FROM @s;
EXECUTE stmt;
END LOOP;
CLOSE cur;
END$$

DROP PROCEDURE IF EXISTS `getShowCreateAllTables`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `getShowCreateAllTables` ()   BEGIN
DECLARE table_name VARCHAR(255);
DECLARE end_of_tables INT DEFAULT 0;
DECLARE cur CURSOR FOR SELECT t.table_name FROM information_schema.tables t  WHERE t.table_schema = DATABASE() AND t.table_type='BASE TABLE';
DECLARE CONTINUE HANDLER FOR NOT FOUND SET end_of_tables = 1;
OPEN cur;

tables_loop: LOOP
FETCH cur INTO table_name;
IF end_of_tables = 1 THEN
	LEAVE tables_loop;
END IF;
SET @s = CONCAT('SHOW CREATE TABLE ' , table_name);
PREPARE stmt FROM @s;
EXECUTE stmt;
END LOOP;
CLOSE cur;
END$$

DROP PROCEDURE IF EXISTS `ShowCreateProcedure`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowCreateProcedure` (IN `db_proc` VARCHAR(250), IN `func_pro` VARCHAR(250))   BEGIN
  SET @a=concat("SHOW CREATE ",func_pro ," ", db_proc);                
  PREPARE stmt1 FROM @a;
  EXECUTE stmt1; 
  DEALLOCATE PREPARE stmt1;
END$$

DROP PROCEDURE IF EXISTS `Test`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Test` (IN `tabname` VARCHAR(20))   BEGIN

DECLARE v1 INT DEFAULT 1;
DECLARE ctids INT DEFAULT 1;
-- SET @ctid= 0;
SELECT ctid FROM ctuktoan WHERE ngay BETWEEN '2020-10-01' AND '2020-12-31' INTO ctids;

WHILE v1 <= 5 DO
  	-- SELECT RIGHT(UNIX_TIMESTAMP()+v1,12) as ctid,v1;
    -- select v1,GetNextCtid() as NextCtid ;
    SET v1 = v1 + 1;
 END WHILE;

IF tabname ='' THEN  SET tabname = 'dmtiente';
END IF;
SELECT @@sql_mode;
SET @table_name = tabname ;                                                                         
SET @s = CONCAT('SELECT ''', @table_name, ''',',  @table_name,'.* FROM ' , @table_name); 
select @s;
PREPARE stmt FROM @s;
EXECUTE stmt;    

END$$

DROP PROCEDURE IF EXISTS `TestServerKetoan`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `TestServerKetoan` (IN `dataname` VARCHAR(20), OUT `nReturn` BIT)  NO SQL BEGIN
    DECLARE resta INT(11);
    SET resta = 0;
 	SELECT count(*) as ncount FROM information_schema.TABLES WHERE TABLE_SCHEMA = dataname AND TABLE_NAME IN ('ctuktoan','ctuvattu','chitiet','hoadon') INTO resta ;
    SET nReturn = 0 ;
    IF resta = 4 THEN
    	SET nReturn = 1 ;
    END IF;
	SELECT nReturn ;    
END$$

DROP PROCEDURE IF EXISTS `TestSizeDatabse`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `TestSizeDatabse` ()  NO SQL SELECT * 
FROM   (SELECT table_schema AS `DB Name`, 
           ROUND(SUM(data_length + index_length) / 1024 / 1024, 1) AS `DB Size in MB`
        FROM   information_schema.tables 
        GROUP BY `DB Name`) AS tmp_table 
ORDER BY `DB Size in MB` DESC$$

DROP PROCEDURE IF EXISTS `TinhCanDoiHangHoa`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `TinhCanDoiHangHoa` (IN `fromd` DATE, IN `tod` DATE)   BEGIN
    DECLARE cnam CHAR (4) DEFAULT concat(YEAR(tod),'');
	DECLARE fromddn DATE DEFAULT MAKEDATE(YEAR(tod),1);	
CALL BoSungMahangPS(fromd,tod);        
UPDATE dmkhohag SET luongnhap=0,tiennhap=0,luongxuat=0,tienxuat=0,luongck=0,tienck=0 WHERE nam = cnam ;
IF fromddn=fromd THEN
	CALL TinhPS_HangHoa(fromd,tod);
	UPDATE dmkhohag AS u SET 
    u.luongck=u.luongdn+u.luongnhap-u.luongxuat ,
    u.tienck=u.tiendn+u.tiennhap-u.tienxuat ,
    u.tiendk=u.tiendn,
    u.luongdk=u.luongdn
    WHERE u.nam=cnam ;
ELSE
    CALL TinhPS_HangHoa(fromddn,DATE_SUB(fromd,INTERVAL 1 DAY));
    UPDATE dmkhohag AS u SET 
    u.luongdk=u.luongdn+u.luongnhap-u.luongxuat ,
    u.tiendk=u.tiendn+u.tiennhap-u.tienxuat 
    WHERE u.nam=cnam ;
	CALL TinhPS_HangHoa(fromd,tod);
	UPDATE dmkhohag AS u SET 
    u.luongck=u.luongdk+u.luongnhap-u.luongxuat ,
    u.tienck=u.tiendk+u.tiennhap-u.tienxuat 
    WHERE u.nam=cnam ;
END IF;

END$$

DROP PROCEDURE IF EXISTS `TinhCanDoiHangHoa2`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `TinhCanDoiHangHoa2` (IN `fromd` DATE, IN `tod` DATE, IN `filter` VARCHAR(50))   BEGIN
DECLARE cnam CHAR (4) DEFAULT concat(year(fromd),'');
CALL TinhCanDoiHangHoa(fromd,tod);
IF filter='' THEN
    SELECT *,us.tenhang, us.donvi FROM dmkhohag AS u INNER JOIN tenhang AS us ON u.mahang = us.mahang WHERE u.nam = cnam order by U.mahang;

ELSE
	SELECT *,us.tenhang, us.donvi FROM dmkhohag AS u INNER JOIN tenhang AS us ON u.mahang = us.mahang WHERE u.nam = cnam AND mahang like (CONCAT(filter, '%')) order by u.mahang;

END IF;
END$$

DROP PROCEDURE IF EXISTS `TinhCanDoiTaiKhoan`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `TinhCanDoiTaiKhoan` (IN `fromd` DATE, IN `tod` DATE)   BEGIN
DECLARE cnam CHAR (4) DEFAULT concat(year(fromd),'');
DECLARE fromddn DATE DEFAULT MAKEDATE(YEAR(tod),1);
CALL BoSungTaiKhoanPS(fromd,tod);

IF fromddn=fromd THEN
	CALL TinhPS_TaiKhoan(fromd,tod);
    UPDATE dmsodutk SET 
    nock = CASE WHEN (nodn-codn+psno-psco)>0 THEN (nodn-codn+psno-psco) ELSE 0 END,
    cock = CASE WHEN (nodn-codn+psno-psco)<0 THEN -(nodn-codn+psno-psco) ELSE 0 END,
	nodk = nodn,
    codk= codn,
    lkpsno=0,lkpsco=0
    WHERE nam = cnam ;
ELSE
	CALL TinhPS_TaiKhoan(fromddn,DATE_SUB(fromd,INTERVAL 1 DAY));
	UPDATE dmsodutk SET
    nodk = CASE WHEN (nodn-codn+psno-psco)>0 THEN (nodn-codn+psno-psco) ELSE 0 END,
    codk = CASE WHEN (nodn-codn+psno-psco)<0 THEN -(nodn-codn+psno-psco) ELSE 0 END,
    lkpsno=psno,lkpsco=psco
    WHERE nam = cnam ;
	CALL TinhPS_TaiKhoan(fromd,tod);
	UPDATE dmsodutk SET 
    nock = CASE WHEN (nodk-codk+psno-psco)>0 THEN (nodk-codk+psno-psco) ELSE 0 END,
    cock = CASE WHEN (nodk-codk+psno-psco)<0 THEN -(nodk-codk+psno-psco) ELSE 0 END
    WHERE nam = cnam ;
END IF;

END$$

DROP PROCEDURE IF EXISTS `TinhCanDoiTaiKhoan2`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `TinhCanDoiTaiKhoan2` (IN `fromd` DATE, IN `tod` DATE, IN `filter` VARCHAR(50))   BEGIN
DECLARE cnam CHAR (4) DEFAULT concat(year(fromd),'');
CALL TinhCanDoiTaiKhoan(fromd,tod);
IF filter='' THEN
	select * from dmsodutk WHERE nam = cnam order by sotk;
ELSE
	select * from dmsodutk WHERE nam = cnam AND sotk like (CONCAT(filter, '%')) order by sotk;
END IF;
END$$

DROP PROCEDURE IF EXISTS `TinhCanDoiTaiKhoanRg`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `TinhCanDoiTaiKhoanRg` (IN `fromd` DATE, IN `tod` DATE)   BEGIN
DECLARE cnam CHAR (4) DEFAULT concat(year(fromd),'');
INSERT INTO candoips (nam,sotk,nodn,codn) 
(select cnam as nam ,sotk,nodn,codn from dmtkhoan where concat(cnam,sotk) not in ( select concat(nam,sotk) from candoips));
UPDATE candoips AS u LEFT JOIN (SELECT uz.tkno as sotk,sum(uz.sotien) as sotien FROM 
(SELECT 
CASE us.ctid WHEN u.ctid THEN us.tkno ELSE u.tkno END as tkno,
CASE us.ctid WHEN u.ctid THEN us.sotien ELSE u.sotien END as sotien
FROM ctuktoan AS u LEFT JOIN chitiet AS us ON u.ctid = us.ctid where u.ngay BETWEEN fromd AND tod ) as uz
GROUP BY 1
) AS us ON u.sotk = us.sotk SET u.psno=us.sotien;
UPDATE candoips AS u LEFT JOIN (SELECT uz.tkco as sotk,sum(uz.sotien) as sotien FROM 
(SELECT 
CASE us.ctid WHEN u.ctid THEN us.tkco ELSE u.tkco END as tkco,
CASE us.ctid WHEN u.ctid THEN us.sotien ELSE u.sotien END as sotien
FROM ctuktoan AS u LEFT JOIN chitiet AS us ON u.ctid = us.ctid where u.ngay BETWEEN fromd AND tod ) as uz
GROUP BY 1
) AS us ON u.sotk = us.sotk SET u.psco=us.sotien;
UPDATE candoips 
SET nock = CASE
  WHEN (nodn-codn+psno-psco)>0 THEN (nodn-codn+psno-psco) ELSE 0 END,
cock = CASE
  WHEN (nodn-codn+psno-psco)<0 THEN -(nodn-codn+psno-psco) ELSE 0 END
WHERE nam = cnam ;
END$$

DROP PROCEDURE IF EXISTS `TinhPS_HangHoa`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `TinhPS_HangHoa` (IN `fromd` DATE, IN `tod` DATE)   BEGIN
    DECLARE cnam CHAR (4) DEFAULT concat(YEAR(tod),'');
    UPDATE dmkhohag AS ux LEFT JOIN
    (SELECT
        u.mahang,
        u.makho,
        SUM(u.soluong) AS luongnhap ,
        SUM(u.sotien) AS tiennhap
    FROM
        ctuvattu AS u
    INNER JOIN ctuktoan AS us
    ON u.ctid = us.ctid AND us.ngay BETWEEN fromd AND tod AND LEFT(us.tkno,3) IN ('151','152','153','155','156','157','158','002','003') 
    GROUP BY 1,2
    ) as uz ON CONCAT(ux.nam,ux.mahang,ux.makho) = CONCAT(cnam,uz.mahang,uz.makho)
    SET ux.luongnhap=uz.luongnhap ,ux.tiennhap=uz.tiennhap ;
    UPDATE dmkhohag AS ux LEFT JOIN
    (SELECT
        u.mahang,
        u.makho,
        SUM(u.soluong) AS luongxuat,
        SUM(u.sotien) AS tienxuat
    FROM
        ctuvattu AS u
    INNER JOIN ctuktoan AS us
    ON u.ctid = us.ctid AND us.ngay BETWEEN fromd AND tod AND LEFT(us.tkco,3) IN ('151','152','153','155','156','157','158','002','003') 
    GROUP BY 1,2
    ) as uz ON CONCAT(ux.nam,ux.mahang,ux.makho) = CONCAT(cnam,uz.mahang,uz.makho) 
    SET ux.luongxuat=uz.luongxuat ,ux.tienxuat=uz.tienxuat ;
END$$

DROP PROCEDURE IF EXISTS `TinhPS_MotBenHH`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `TinhPS_MotBenHH` (IN `fromd` DATE, IN `tod` DATE, IN `nbenno` INT, IN `cmahang` CHAR(10))   BEGIN
DECLARE cnam CHAR (4) DEFAULT concat(year(fromd),'');
IF nbenno =1 THEN
	IF cmahang='' THEN
        (SELECT us.ngay,
        us.tkno,us.matkno,
        us.tkco,us.matkco,
        u.mahang,
        u.makho,
        SUM(u.soluong) AS luongnhap ,
        SUM(u.sotien) AS tiennhap
        FROM
        ctuvattu AS u
        INNER JOIN ctuktoan AS us
        ON u.ctid = us.ctid WHERE us.ngay BETWEEN fromd AND tod AND LEFT(us.tkno,3) IN ('151','152','153','155','156','157','158','002','003') 
    GROUP BY 1,2,3,4,5,6
    ) ;
    ELSE
         (SELECT us.ngay,
        us.tkno,us.matkno,
        us.tkco,us.matkco,
        u.mahang,
        u.makho,
        SUM(u.soluong) AS luongnhap ,
        SUM(u.sotien) AS tiennhap
        FROM
        ctuvattu AS u
        INNER JOIN ctuktoan AS us
        ON u.ctid = us.ctid WHERE us.ngay BETWEEN fromd AND tod AND LEFT(us.tkno,3) IN ('151','152','153','155','156','157','158','002','003') AND  	u.mahang=cmahang
    GROUP BY 1,2,3,4,5,6
    ) ;
	END IF;
ELSE
	IF cmahang='' THEN
        (SELECT
        us.tkco,us.matkco,
        us.tkno,us.matkno, 
        u.mahang,
        u.makho,
        SUM(u.soluong) AS luongxuat,
        SUM(u.sotien) AS tienxuat
    FROM
        ctuvattu AS u
    INNER JOIN ctuktoan AS us
    ON u.ctid = us.ctid WHERE us.ngay BETWEEN fromd AND tod AND LEFT(us.tkco,3) IN ('151','152','153','155','156','157','158','002','003') 
    GROUP BY 1,2,3,4,5,6
    )  ;
    ELSE
         (SELECT
        us.tkco,us.matkco,
        us.tkno,us.matkno, 
        u.mahang,
        u.makho,
        SUM(u.soluong) AS luongxuat,
        SUM(u.sotien) AS tienxuat
    FROM
        ctuvattu AS u
    INNER JOIN ctuktoan AS us
    ON u.ctid = us.ctid WHERE us.ngay BETWEEN fromd AND tod AND LEFT(us.tkco,3) IN ('151','152','153','155','156','157','158','002','003') AND  	u.mahang=cmahang
    GROUP BY 1,2,3,4,5,6
    )  ;
	END IF;
END IF ;
END$$

DROP PROCEDURE IF EXISTS `TinhPS_MotBenTK`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `TinhPS_MotBenTK` (IN `fromd` DATE, IN `tod` DATE, IN `nbenno` BIT, IN `csotk` CHAR(8))  NO SQL BEGIN
DECLARE cnam CHAR (4) DEFAULT concat(year(fromd),'');
IF nbenno =1 THEN
	IF csotk='' THEN
         (SELECT uz.tkno,uz.matkno,uz.tkco,uz.matkco,sum(uz.sotien) as sotien,sum(uz.ngoaite) as ngoaite FROM 
        (SELECT 
        CASE us.ctid WHEN u.ctid THEN us.tkno ELSE u.tkno END as tkno,
   		CASE us.ctid WHEN u.ctid THEN us.matkno ELSE u.matkno END as matkno,
        CASE us.ctid WHEN u.ctid THEN us.tkco ELSE u.tkco END as tkco,
        CASE us.ctid WHEN u.ctid THEN us.matkco ELSE u.matkco END as matkco, 
        CASE us.ctid WHEN u.ctid THEN us.sotien ELSE u.sotien END as sotien,
        CASE us.ctid WHEN u.ctid THEN us.ngoaite ELSE u.ngoaite END as ngoaite
        FROM ctuktoan AS u LEFT JOIN chitiet AS us ON u.ctid = us.ctid where u.ngay BETWEEN fromd AND tod ) as uz WHERE 1
        GROUP BY 1,2,3,4
        ) ;
    ELSE
        (SELECT uz.tkno,uz.matkno,uz.tkco,uz.matkco,sum(uz.sotien) as sotien,sum(uz.ngoaite) as ngoaite FROM 
        (SELECT 
        CASE us.ctid WHEN u.ctid THEN us.tkno ELSE u.tkno END as tkno,
   		CASE us.ctid WHEN u.ctid THEN us.matkno ELSE u.matkno END as matkno,
        CASE us.ctid WHEN u.ctid THEN us.tkco ELSE u.tkco END as tkco,
        CASE us.ctid WHEN u.ctid THEN us.matkco ELSE u.matkco END as matkco, 
        CASE us.ctid WHEN u.ctid THEN us.sotien ELSE u.sotien END as sotien,
        CASE us.ctid WHEN u.ctid THEN us.ngoaite ELSE u.ngoaite END as ngoaite
        FROM ctuktoan AS u LEFT JOIN chitiet AS us ON u.ctid = us.ctid where u.ngay BETWEEN fromd AND tod ) as uz WHERE uz.tkno=csotk
        GROUP BY 1,2,3,4
        ) ;
	END IF;
ELSE
	IF csotk='' THEN
       (SELECT uzz.tkco,uzz.matkco,uzz.tkno  ,uzz.matkno,sum(uzz.sotien) as sotien,sum(uzz.ngoaite) as ngoaite FROM 
        (SELECT 
        CASE uss.ctid WHEN uu.ctid THEN uss.tkco ELSE uu.tkco END as tkco,
        CASE uss.ctid WHEN uu.ctid THEN uss.matkco ELSE uu.matkco END as matkco,
        CASE uss.ctid WHEN uu.ctid THEN uss.tkno ELSE uu.tkno END as tkno, 
        CASE uss.ctid WHEN uu.ctid THEN uss.matkno ELSE uu.matkno END as matkno,
         CASE uss.ctid WHEN uu.ctid THEN uss.sotien ELSE uu.sotien END as sotien,
        CASE uss.ctid WHEN uu.ctid THEN uss.ngoaite ELSE uu.ngoaite END as ngoaite
        FROM ctuktoan AS uu LEFT JOIN chitiet AS uss ON uu.ctid = uss.ctid where uu.ngay BETWEEN fromd AND tod ) as uzz WHERE 1
        GROUP BY 1 ,2,3,4
        ) ;
    ELSE
        (SELECT uzz.tkco,uzz.matkco,uzz.tkno  ,uzz.matkno,sum(uzz.sotien) as sotien,sum(uzz.ngoaite) as ngoaite FROM 
        (SELECT 
        CASE uss.ctid WHEN uu.ctid THEN uss.tkco ELSE uu.tkco END as tkco,
        CASE uss.ctid WHEN uu.ctid THEN uss.matkco ELSE uu.matkco END as matkco,
        CASE uss.ctid WHEN uu.ctid THEN uss.tkno ELSE uu.tkno END as tkno, 
        CASE uss.ctid WHEN uu.ctid THEN uss.matkno ELSE uu.matkno END as matkno,
         CASE uss.ctid WHEN uu.ctid THEN uss.sotien ELSE uu.sotien END as sotien,
        CASE uss.ctid WHEN uu.ctid THEN uss.ngoaite ELSE uu.ngoaite END as ngoaite
        FROM ctuktoan AS uu LEFT JOIN chitiet AS uss ON uu.ctid = uss.ctid where uu.ngay BETWEEN fromd AND tod ) as uzz WHERE uzz.tkco=csotk
        GROUP BY 1 ,2,3,4
        ) ;
	END IF;
END IF ;
END$$

DROP PROCEDURE IF EXISTS `TinhPS_MotBenTK_Rg`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `TinhPS_MotBenTK_Rg` (IN `fromd` DATE, IN `tod` DATE, IN `nbenno` BIT, IN `nlentk` TINYINT(1))  NO SQL BEGIN
DECLARE cnam CHAR (4) DEFAULT concat(year(fromd),'');
IF (nlentk <= 0) THEN SET nlentk = 1 ;
END IF ;
IF nbenno =1 THEN
    SELECT LEFT(tc.tkno,nlentk) as tkno ,'' as matkno ,LEFT(tc.tkco,nlentk) as tkco ,'' as matkco ,sum(tc.sotien) as sotien,sum(tc.ngoaite) ngoaite FROM 
         (SELECT uz.tkno,uz.matkno,uz.tkco,uz.matkco,sum(uz.sotien) as sotien,sum(uz.ngoaite) as ngoaite FROM 
        (SELECT 
        CASE us.ctid WHEN u.ctid THEN us.tkno ELSE u.tkno END as tkno,
   		CASE us.ctid WHEN u.ctid THEN us.matkno ELSE u.matkno END as matkno,
        CASE us.ctid WHEN u.ctid THEN us.tkco ELSE u.tkco END as tkco,
        CASE us.ctid WHEN u.ctid THEN us.matkco ELSE u.matkco END as matkco, 
        CASE us.ctid WHEN u.ctid THEN us.sotien ELSE u.sotien END as sotien,
        CASE us.ctid WHEN u.ctid THEN us.ngoaite ELSE u.ngoaite END as ngoaite
        FROM ctuktoan AS u LEFT JOIN chitiet AS us ON u.ctid = us.ctid where u.ngay BETWEEN fromd AND tod ) as uz WHERE 1
        GROUP BY 1,2,3,4
        )  AS tc GROUP BY 1,2,3,4
    ;
ELSE
    SELECT LEFT(tc.tkco,nlentk) as tkco ,'' as matkco ,LEFT(tc.tkno,nlentk) as tkno ,'' as matkno ,sum(tc.sotien) as sotien,sum(tc.ngoaite) ngoaite FROM 
       (SELECT uzz.tkco,uzz.matkco,uzz.tkno  ,uzz.matkno,sum(uzz.sotien) as sotien,sum(uzz.ngoaite) as ngoaite FROM 
        (SELECT 
        CASE uss.ctid WHEN uu.ctid THEN uss.tkco ELSE uu.tkco END as tkco,
        CASE uss.ctid WHEN uu.ctid THEN uss.matkco ELSE uu.matkco END as matkco,
        CASE uss.ctid WHEN uu.ctid THEN uss.tkno ELSE uu.tkno END as tkno, 
        CASE uss.ctid WHEN uu.ctid THEN uss.matkno ELSE uu.matkno END as matkno,
         CASE uss.ctid WHEN uu.ctid THEN uss.sotien ELSE uu.sotien END as sotien,
        CASE uss.ctid WHEN uu.ctid THEN uss.ngoaite ELSE uu.ngoaite END as ngoaite
        FROM ctuktoan AS uu LEFT JOIN chitiet AS uss ON uu.ctid = uss.ctid where uu.ngay BETWEEN fromd AND tod ) as uzz WHERE 1
        GROUP BY 1 ,2,3,4
        )  AS tc GROUP BY 1,2,3,4
    ;
END IF ;
END$$

DROP PROCEDURE IF EXISTS `TinhPS_TaiKhoan`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `TinhPS_TaiKhoan` (IN `fromd` DATE, IN `tod` DATE)   BEGIN
DECLARE cnam CHAR (4) DEFAULT concat(year(fromd),'');
UPDATE dmsodutk SET psno=0,psco=0,ngoaite=0 WHERE nam=cnam ;
UPDATE dmsodutk AS cd INNER JOIN
(SELECT uz.tkno,uz.tkhoan,sum(uz.sotien) as sotien,sum(uz.ngoaite) as ngoaite FROM 
(SELECT 
CASE us.ctid WHEN u.ctid THEN us.tkno ELSE u.tkno END as tkno,
CASE us.ctid WHEN u.ctid THEN us.matkno ELSE u.matkno END as tkhoan, 
CASE us.ctid WHEN u.ctid THEN us.sotien ELSE u.sotien END as sotien,
CASE us.ctid WHEN u.ctid THEN us.ngoaite ELSE u.ngoaite END as ngoaite
FROM ctuktoan AS u LEFT JOIN chitiet AS us ON u.ctid = us.ctid where u.ngay BETWEEN fromd AND tod ) as uz
GROUP BY 1,2
) 
AS pn ON CONCAT(cd.nam,cd.sotk,cd.tkhoan) = CONCAT(cnam,pn.tkno,pn.tkhoan)
SET cd.psno=pn.sotien,cd.ngoaite=pn.ngoaite;
UPDATE dmsodutk AS cd INNER JOIN
(SELECT uz.tkco ,uz.tkhoan,sum(uz.sotien) as sotien,sum(uz.ngoaite) as ngoaite FROM 
(SELECT 
CASE us.ctid WHEN u.ctid THEN us.tkco ELSE u.tkco END as tkco,
CASE us.ctid WHEN u.ctid THEN us.matkco ELSE u.matkco END as tkhoan,  
CASE us.ctid WHEN u.ctid THEN us.sotien ELSE u.sotien END as sotien,
CASE us.ctid WHEN u.ctid THEN us.ngoaite ELSE u.ngoaite END as ngoaite
FROM ctuktoan AS u LEFT JOIN chitiet AS us ON u.ctid = us.ctid where u.ngay BETWEEN fromd AND tod ) as uz
GROUP BY 1,2
) 
AS pn ON CONCAT(cd.nam,cd.sotk,cd.tkhoan) = CONCAT(cnam,pn.tkco,pn.tkhoan) 
SET cd.psco=pn.sotien,cd.ngoaite=pn.ngoaite;
END$$

DROP PROCEDURE IF EXISTS `UpdateMaHangKho`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateMaHangKho` (IN `cmahang` CHAR(10), IN `cmakho` CHAR(3), IN `tod` DATE, OUT `nsuccess` INT(10))   BEGIN
DECLARE cnam CHAR(4) DEFAULT CONCAT(year(tod),'') ;
SELECT count(*) into nsuccess FROM dmkhohag AS u
  WHERE CONCAT(u.nam,u.mahang,u.makho)= CONCAT(cnam,cmahang,cmakho) ;
	IF (nsuccess >= 1) then
  		SELECT 1 INTO nsuccess;
    ELSE
      	INSERT into dmkhohag (nam,mahang,makho) values (cnam,cmahang,cmakho);
      	SELECT 2 INTO nsuccess;
	END IF;
    SELECT  nsuccess;
END$$

DROP PROCEDURE IF EXISTS `UpdateSotkTkhoan`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSotkTkhoan` (IN `csotk` CHAR(8), IN `ctkhoan` CHAR(6), IN `tod` DATE, OUT `nsuccess` INT(10))   BEGIN
DECLARE cnam CHAR(4) DEFAULT CONCAT(year(tod),'') ;
SELECT count(*) into nsuccess FROM dmsodutk AS u
  WHERE CONCAT(u.nam,u.sotk,u.tkhoan)= CONCAT(cnam,csotk,ctkhoan) ;
    IF (nsuccess >= 1) then
    	SELECT 1 INTO nsuccess;
    ELSE
      INSERT into dmsodutk (nam,sotk,tkhoan) values (cnam,csotk,ctkhoan);
      SELECT 2 INTO nsuccess;
	END IF;
    SELECT  nsuccess;
END$$

DROP PROCEDURE IF EXISTS `Watch_InfoMysql`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Watch_InfoMysql` ()   BEGIN
    show variables like "dalocalhost" ;
	show variables like "pid_filelocalhost" ;
    show variables like "innodb_data_home_dirlocalhost" ;
    show variables like "basedirlocalhost" ;
	show variables like "socketlocalhost" ;
    show variables like "tmpdirlocalhost" ;
    show variables like "versionlocalhost" ;
    show variables like "sqllocalhost" ;
    show variables like "clocalhost" ;
END$$

--
-- Các hàm
--
DROP FUNCTION IF EXISTS `Example`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `Example`() RETURNS varchar(1000) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE NextID INT DEFAULT 0;
        UPDATE quanlykt set numid=numid+1 where UPPER(tentaptin)='CTUKTOAN'; 
        SELECT numid INTO NextID FROM quanlykt where UPPER(tentaptin)='CTUKTOAN';

        IF NextID=0 THEN
            SELECT MAX(ABS(ctid))+1 INTO NextID from ctuktoan;
            INSERT INTO quanlykt (tentaptin,numid ) VALUES ('CTUKTOAN', NextID);
    	END IF;

	RETURN NextID;    
END$$

DROP FUNCTION IF EXISTS `GetNextCtid`$$
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `GetNextCtid`() RETURNS int
    DETERMINISTIC
BEGIN
    DECLARE NextID INT DEFAULT 0;
        UPDATE quanlykt set numid=numid+1 where UPPER(tentaptin)='CTUKTOAN'; 
        SELECT numid INTO NextID FROM quanlykt where UPPER(tentaptin)='CTUKTOAN';

        IF NextID=0 THEN
            SELECT MAX(ABS(ctid))+1 INTO NextID from ctuktoan;
            INSERT INTO quanlykt (tentaptin,numid ) VALUES ('CTUKTOAN', NextID);
    	END IF;

	RETURN NextID;    
END$$

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cdketoan`
--

DROP TABLE IF EXISTS `cdketoan`;
CREATE TABLE `cdketoan` (
  `id` int(10) NOT NULL,
  `chedokt` char(10) NOT NULL,
  `kyhieu` char(2) NOT NULL,
  `masc` char(6) NOT NULL,
  `tentsc` char(80) NOT NULL,
  `tentscu` char(80) NOT NULL,
  `tk1` char(80) NOT NULL,
  `tmtsc` char(5) NOT NULL,
  `tscd` decimal(15,2) NOT NULL,
  `tscc` decimal(15,2) NOT NULL,
  `masn` char(6) NOT NULL,
  `tentsn` char(80) NOT NULL,
  `tentsnu` char(80) NOT NULL,
  `tk2` char(80) NOT NULL,
  `tmtsn` char(5) NOT NULL,
  `tsnd` decimal(15,2) NOT NULL,
  `tsnc` decimal(15,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `cdketoan`
--

INSERT INTO `cdketoan` (`id`, `chedokt`, `kyhieu`, `masc`, `tentsc`, `tentscu`, `tk1`, `tmtsc`, `tscd`, `tscc`, `masn`, `tentsn`, `tentsnu`, `tk2`, `tmtsn`, `tsnd`, `tsnc`) VALUES
(335, 'DNL', '98', '100**', 'A.TÀI SẢN L/ĐỘNG & ĐẦU TƯ NGẮN HẠN', 'A.CURRENT ASSERTS AND SHORT-TERM IN', '1-129-139-159,3', '', '0.00', '0.00', '300*', 'A.NỢ PHẢI TRẢ', 'A.LIABILITIES', '3,13-139,14', '', '2062267216.00', '2062267216.00'),
(336, 'DNL', '98', '110*', 'I.Tiền', 'I. Capital in cash', '11', '', '0.00', '0.00', '310*', 'I.Nợ ngắn hạn', 'I.Current liabilities', '31,33-3381-335,13-139,14', '', '2062267216.00', '2062267216.00'),
(337, 'DNL', '98', '111', ' 1.Tiền mặt tại quỹ (cả ngân phiếu)', ' 1.Cash in hand (including notes)', '111', '', '0.00', '0.00', '311', ' 1.Vay ngắn hạn', ' 1.Short-term borrowings', '311', '', '570000000.00', '570000000.00'),
(338, 'DNL', '98', '112', ' 2.Tiền gửi ngân hàng', ' 2.Cash in bank', '112', '', '0.00', '0.00', '312', ' 2.Nợ dài hạn đến hạn trả', ' 2.Long-term due liabilities', '315', '', '0.00', '0.00'),
(339, 'DNL', '98', '113', ' 3.Tiền đang chuyển', ' 3.Cash in transit', '113', '', '0.00', '0.00', '313', ' 3.Phải trả cho người bán', ' 3.Payables to seller', '331', '', '554807422.00', '554807422.00'),
(340, 'DNL', '98', '120*', 'II.Các khoản Đầu tư t/chính ng/hạn', 'II.Fiancial short-term investment', '12-129', '', '0.00', '0.00', '314', ' 4.Người mua trả tiền trước', ' 4.Prepaid by buyers', '131', '', '591442331.00', '591442331.00'),
(341, 'DNL', '98', '121', ' 1.Đầu tư chứng khoán ngắn hạn', ' 1.Short-term securities', '121', '', '0.00', '0.00', '315', ' 5.Thuế và các khoản phải nộp NN', ' 5.Tax and obligation to state', '333', '', '198546996.00', '198546996.00'),
(342, 'DNL', '98', '128', ' 2.Đầu tư ngắn hạn khác', ' 2.Other short-term investment', '128', '', '0.00', '0.00', '316', ' 6.Phải trả công nhân viên', ' 6.Payables to employees', '334', '', '22397877.00', '22397877.00'),
(343, 'DNL', '98', '129', ' 3.Dự phòng giãm giá đầu tư ng/hạn', ' 3.Provision for short-term investm', '129', '', '0.00', '0.00', '317', ' 7.Phải trả cho đơn vị nội bộ', ' 7.Internal payables', '336,136', '', '0.00', '0.00'),
(344, 'DNL', '98', '130*', 'III.Các khoản phải thu', 'III.Receivable accounts', '13-1381-139,3', '', '0.00', '0.00', '318', ' 8.Khoản phải trả ,phải nộp khác', ' 8.Others', '338-3381,13-136-139-131,14', '', '10964657.00', '10964657.00'),
(345, 'DNL', '98', '131', ' 1.Phải thu khách hàng', ' 1.Receivable from customers', '131', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(346, 'DNL', '98', '132', ' 2.Trả trước cho người bán', ' 2.Prepaid to seller', '331', '', '0.00', '0.00', '320*', 'II.Nợ dài hạn', 'II.Long-term liabilities', '34-344', '', '0.00', '0.00'),
(347, 'DNL', '98', '133', ' 3.Phải thu nội bộ', ' 3.internal receivables', '136', '', '0.00', '0.00', '321', ' 1.Vay dài hạn', ' 1.Long-term borrowings', '341', '', '0.00', '0.00'),
(348, 'DNL', '98', '134', '   - Vốn KD ở các đơn vị trực thuộc', '   - Working capital in sub-units', '1361', '', '0.00', '0.00', '322', ' 2.Nợ dài hạn', ' 2.Long-term loans', '342', '', '0.00', '0.00'),
(349, 'DNL', '98', '135', '   - Phải thu nội bộ khác', '   - Others', '1362', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(350, 'DNL', '98', '138', ' 4.Các khoản phải thu khác', ' 4.Other receivables', '138-1381,3-331', '', '0.00', '0.00', '330*', 'III.Nợ khác', 'III.Others', '335,3381,344', '', '114107933.00', '114107933.00'),
(351, 'DNL', '98', '139', ' 5.Dự phòng khoản phải thu khó đòi', ' 5.Provision for bad loans', '139', '', '0.00', '0.00', '331', ' 1.Chi phí phải trả', ' 1.Payable cost', '335', '', '114107933.00', '114107933.00'),
(352, 'DNL', '98', '140*', 'IV.Hàng tồn kho', 'IV.Inventories', '15-159', '', '0.00', '0.00', '332', ' 2.Tài sản thừa chờ xử lý', ' 2.Surplus under pendency', '3381', '', '0.00', '0.00'),
(353, 'DNL', '98', '141', ' 1.Hàng mua đang đi trên đường', ' 1.Goods in transfer', '151', '', '0.00', '0.00', '333', ' 3.Nhận ký quỹ ,ký cược dài hạn', ' 3.Receipts of long-term deposits', '344', '', '0.00', '0.00'),
(354, 'DNL', '98', '142', ' 2.Nguyên liệu,vật liệu tồn kho', ' 2.Raw materials', '152', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(355, 'DNL', '98', '143', ' 3.Công cụ ,dung cụ trong kho', ' 3.Tools and intruments', '153', '', '0.00', '0.00', '400*', 'B.NGUỒN VỐN CHỦ SỞ HỮU', 'B.OWNER`S EQUITY', '4,412,413,421,431', '', '993655624.00', '993655624.00'),
(356, 'DNL', '98', '144', ' 4.Chi phí sản xuất KD dở dang', ' 4.Work in process', '154', '', '0.00', '0.00', '410*', 'I.Vốn - quỹ', 'I.Capital sourses and funds', '41,42,43,44,412,413,421,431', '', '993655624.00', '993655624.00'),
(357, 'DNL', '98', '145', ' 5.Thành phẩm tồn kho', ' 5.Finished products', '155', '', '0.00', '0.00', '411', ' 1.Vốn kinh doanh', ' 1.Business capital', '411', '', '849468096.00', '849468096.00'),
(358, 'DNL', '98', '146', ' 6.Hàng hoá tồn kho', ' 6.Goods in stock', '156', '', '0.00', '0.00', '412', ' 2.Chênh lệch đánh giá lại tài sản', ' 2.Differences of revaluation', '412', '', '0.00', '0.00'),
(359, 'DNL', '98', '147', ' 7.Hàng gửi đi bán', ' 7.Consigned goods for sale', '157', '', '0.00', '0.00', '413', ' 3.Chênh lệch tỷ giá', ' 3.Differences of exchange rate', '413', '', '0.00', '0.00'),
(360, 'DNL', '98', '149', ' 8.Dự phòng giãm giá hàng tồn', ' 8.Provision for inventories', '159', '', '0.00', '0.00', '414', ' 4.Quỹ đầu tư phát triển', ' 4.Business development funds', '414', '', '24170780.00', '24170780.00'),
(361, 'DNL', '98', '150*', 'V.Tài sản lưu động khác', 'V.Other current assets', '14,1381', '', '0.00', '0.00', '415', ' 5.Quỹ dự phòng tài chính', ' 5.Reserved funds', '415', '', '0.00', '0.00'),
(362, 'DNL', '98', '151', ' 1.Tạm ứng', ' 1.Advances', '141', '', '0.00', '0.00', '416', ' 6.Quỹ dự phòng trợ cấp mất việc', ' 6.Reserved funds', '416', '', '-10688000.00', '-10688000.00'),
(363, 'DNL', '98', '152', ' 2.Chi phí trả trước', ' 2.Prepaid costs', '1421', '', '0.00', '0.00', '417', ' 7.Lãi chưa phân phối', ' 7.Undestributed profit', '421', '', '92853580.00', '92853580.00'),
(364, 'DNL', '98', '153', ' 3.Chi phí chờ kết chuyển', ' 3.Pending costs for transfer', '1422', '', '0.00', '0.00', '418', ' 8.Quỹ khen thưởng phúc lợi', ' 8.Reward and benifit funds', '431', '', '37851168.00', '37851168.00'),
(365, 'DNL', '98', '154', ' 4.Tài sản thiếu chờ xử lý', ' 4.Loss under pendency', '1381', '', '0.00', '0.00', '', ' 9.Nguồn vốn đầu tư xây dựng cơ bản', ' 9.Capital investment sourses', '441', '', '0.00', '0.00'),
(366, 'DNL', '98', '155', ' 5.Khoản thế chấp,ký cược,ký quỹ NH', ' 5.Short-term mortgage and deposit', '144', '', '0.00', '0.00', '420*', 'II.Nguồn kinh phí', 'II.Budget resources', '45,46', '', '0.00', '0.00'),
(367, 'DNL', '98', '160*', 'VI.Chi sự nghiệp', 'VI.Administratvie', '161', '', '0.00', '0.00', '421', ' 1.Quỹ quản lý của cấp trên', ' 1.Management funds of higher level', '451', '', '0.00', '0.00'),
(368, 'DNL', '98', '161', ' 1.Chi sự nghiệp năm trước', ' 1.For previous year', '1611', '', '0.00', '0.00', '422', ' 2.Nguồn kinh phí sự nghiệp', ' 2.Administrative funds', '461', '', '0.00', '0.00'),
(369, 'DNL', '98', '162', ' 2.Chi sự nghiệp năm nay', ' 2.For current year', '1612', '', '0.00', '0.00', '423', '   - Nguồn kinh phí năm trước', '  - Of previous year', '4611', '', '0.00', '0.00'),
(370, 'DNL', '98', '200**', 'B.TÀI SẢN CỐ ĐỊNH & ĐẦU TƯ DÀI HẠN', 'B.FIXED ASSETS AND LONGTERM INVERST', '2-214-229', '', '0.00', '0.00', '424', '   - Nguồn kinh phí năm nay', '  - Of current year', '4612', '', '0.00', '0.00'),
(371, 'DNL', '98', '210*', 'I.Tài sản cố định', 'I.Fixed assets', '21-214', '', '0.00', '0.00', '425', ' 3.Nguồn kinh phí đã h/thành TSCĐ', ' 3.Administrative funds', '466', '', '0.00', '0.00'),
(372, 'DNL', '98', '211', ' 1.Tài sản cố định hữu hình', ' 1.Tangible fixed assets', '211,2141', '', '0.00', '0.00', '', '', '', '', '', '3055922840.00', '3055922840.00'),
(373, 'DNL', '98', '212', '   - Nguyên giá', '  - Original rate', '211', '', '0.00', '0.00', '430*', '       TỔNG CỘNG NGUỒN VỐN', '         TOTAL RESOURCES', '3,13-139,4,412,413,421,431,14', '', '0.00', '0.00'),
(374, 'DNL', '98', '213', '   - Giá trị hao mòn luỹ kế', '  - Accumulated depreciation', '2141', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(375, 'DNL', '98', '214', ' 2.Tài sản cố định thuê tài chính', ' 2.Leased financial assets', '212,2142', '', '0.00', '0.00', '   *', '                  CÁC CHỈ TIÊU', '', '', '', '0.00', '0.00'),
(376, 'DNL', '98', '215', '   - Nguyên giá', '  - Original rate', '212', '', '0.00', '0.00', '   *', '    NGOÀI BẢNG CÂN ĐỐI KÊ TOÁN', '----------  INDICATORS ------------', '', '', '0.00', '0.00'),
(377, 'DNL', '98', '216', '   - Giá trị hao mòn luỹ kế', '  - Accumulated depreciation', '2142', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(378, 'DNL', '98', '217', ' 3.Tài sản cố định vô hình', ' 1.Intangible fixed assets', '213,2143', '', '0.00', '0.00', '', ' 1.Tài sản thuê ngoài', '1.Leased assets from outside', '001', '', '0.00', '0.00'),
(379, 'DNL', '98', '218', '   - Nguyên giá', '  - Original rate', '213', '', '0.00', '0.00', '', ' 2.Vật tư hàng hoá giữ hộ,gia công', '2.Materials and goods entrusted for', '002', '', '0.00', '0.00'),
(380, 'DNL', '98', '219', '   - Giá trị hao mòn luỹ kế', '  - Accumulated depreciation', '2143', '', '0.00', '0.00', '', ' 3.Hàng hoá nhận bán hộ ,ký gửi', '3.Goods to be consigned and depsite', '003', '', '0.00', '0.00'),
(381, 'DNL', '98', '220*', 'II.Các khoản đầu tư t/chính dài hạn', 'II.Long-term Financial investment', '22-229', '', '0.00', '0.00', '', ' 4.Nợ khó đòi đã xử lý', '4.Settled bad loans', '004', '', '0.00', '0.00'),
(382, 'DNL', '98', '221', ' 1.Đầu tư chứng khoán dài hạn', ' 1.Long-term securities', '221', '', '0.00', '0.00', '', ' 5.Ngoại tệ các loại', '5.Foreign currencies', '007', '', '0.00', '0.00'),
(383, 'DNL', '98', '222', ' 2.Góp vốn liên doanh', ' 2.Join-venture contribution', '222', '', '0.00', '0.00', '', '   -Tiền mặt Việt Nam', '  - ...', '0071', '', '0.00', '0.00'),
(384, 'DNL', '98', '228', ' 3.Các khoản đầu tư dài hạn khác', ' 3.Others', '228', '', '0.00', '0.00', '', '   -...', '  - ...', '0072', '', '0.00', '0.00'),
(385, 'DNL', '98', '229', ' 4.Dự phòng giãm giá đầu tư dài hạn', ' 4.Provision for devaluation', '229', '', '0.00', '0.00', '', '   -...', '  - ...', '0073', '', '0.00', '0.00'),
(386, 'DNL', '98', '230*', 'III.Chi phí xây dựng cơ bản dở dang', 'III.Cost for contruction in process', '241', '', '0.00', '0.00', '', ' 6.Hạn mức kinh phí còn lại', '6.Available depreciation amount', '008', '', '0.00', '0.00'),
(387, 'DNL', '98', '240*', 'IV.Các khoản ký quỹ,ký cược dài hạn', 'IV.Long-term deposits', '244', '', '0.00', '0.00', '', ' 7.Nguồn vốn kh/hao cơ bản hiện có', '', '009', '', '0.00', '0.00'),
(388, 'DNL', '98', '250*', '         TỔNG CỘNG TÀI SẢN', '            TOTAL ASSETS', '1-129-139-159,2-214-229,3', '', '0.00', '0.00', '   *', '     CÔNG TAI SAN NGOAI BANG', '         TOTAL INDICATORS', '00', '', '0.00', '0.00'),
(389, 'DNL', '99', '100*', 'A.TÀI SẢN LĐ & ĐẦU TƯ NGẮN HẠN', 'A.CURRENT ASSERTS AND SHORT-TERM IN', '1-16-129-139-159,3', '', '0.00', '0.00', '300*', 'A.NỢ PHẢI TRẢ', 'A.LIABILITIES', '3,13-139,14', '', '2062267216.00', '2062267216.00'),
(390, 'DNL', '99', '110*', 'I.Tiền', 'I. Capital in cash', '11', '', '0.00', '0.00', '310*', 'I.Nợ ngắn hạn', 'I.Current liabilities', '31,33-3381-335,13-139,14', '', '2062267216.00', '2062267216.00'),
(391, 'DNL', '99', '111', ' 1.Tiền mặt tại quỹ (gồm cả ngân phiếu)', ' 1.Cash in hand (including notes)', '111', '', '0.00', '0.00', '311', ' 1.Vay ngắn hạn', ' 1.Short-term borrowings', '311', '', '570000000.00', '570000000.00'),
(392, 'DNL', '99', '112', ' 2.Tiền gửi ngân hàng', ' 2.Cash in bank', '112', '', '0.00', '0.00', '312', ' 2.Nợ dài hạn đến hạn trả', ' 2.Long-term due liabilities', '315', '', '0.00', '0.00'),
(393, 'DNL', '99', '113', ' 3.Tiền đang chuyển', ' 3.Cash in transit', '113', '', '0.00', '0.00', '313', ' 3.Phải trả cho người bán', ' 3.Payables to seller', '331', '', '554807422.00', '554807422.00'),
(394, 'DNL', '99', '120*', 'II.Các khoản Đầu tư t/chính ng/hạn', 'II.Fiancial short-term investment', '12-129', '', '0.00', '0.00', '314', ' 4.Người mua trả tiền trước', ' 4.Prepaid by buyers', '131', '', '591442331.00', '591442331.00'),
(395, 'DNL', '99', '121', ' 1.Đầu tư chứng khoán ngắn hạn', ' 1.Short-term securities', '121', '', '0.00', '0.00', '315', ' 5.Thuế và các khoản phải nộp NN', ' 5.Tax and obligation to state', '333', '', '198546996.00', '198546996.00'),
(396, 'DNL', '99', '128', ' 2.Đầu tư ngắn hạn khác', ' 2.Other short-term investment', '128', '', '0.00', '0.00', '316', ' 6.Phải trả công nhân viên', ' 6.Payables to employees', '334', '', '22397877.00', '22397877.00'),
(397, 'DNL', '99', '129', ' 3.Dự phòng giãm giá đầu tư ng/hạn (*)', ' 3.Provision for short-term investm', '129', '', '0.00', '0.00', '317', ' 7.Phải trả cho đơn vị nội bộ', ' 7.Internal payables', '336,136', '', '0.00', '0.00'),
(398, 'DNL', '99', '130*', 'III.Các khoản phải thu', 'III.Receivable accounts', '13-1381-139,3', '', '0.00', '0.00', '318', ' 8.Khoản phải trả ,phải nộp khác', ' 8.Others', '338-3381,13-139-131-136,14', '', '10964657.00', '10964657.00'),
(399, 'DNL', '99', '131', ' 1.Phải thu khách hàng', ' 1.Receivable from customers', '131', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(400, 'DNL', '99', '132', ' 2.Trả trước cho người bán', ' 2.Prepaid to seller', '331', '', '0.00', '0.00', '320*', 'II.Nợ dài hạn', 'II.Long-term liabilities', '34-344', '', '0.00', '0.00'),
(401, 'DNL', '99', '133', ' 3.Thuế giá trị gia tăng được khấu trừ', ' 3.VAT discountable', '133', '', '0.00', '0.00', '321', ' 1.Vay dài hạn', ' 1.Long-term borrowings', '341', '', '0.00', '0.00'),
(402, 'DNL', '99', '134', ' 4.Phải thu nội bộ', ' 4.internal receivables', '136', '', '0.00', '0.00', '322', ' 2.Nợ dài hạn', ' 2.Long-term loans', '342', '', '0.00', '0.00'),
(403, 'DNL', '99', '135', '   - Vốn KD ở các đơn vị trực thuộc', '   - Working capital in sub-units', '1361', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(404, 'DNL', '99', '136', '   - Phải thu nội bộ khác', '   - Others', '1362', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(405, 'DNL', '99', '138', ' 5.Các khoản phải thu khác', ' 5.Other receivables', '138-1381,3-331', '', '0.00', '0.00', '330*', 'III.Nợ khác', 'III.Others', '335,3381,344', '', '114107933.00', '114107933.00'),
(406, 'DNL', '99', '139', ' 6.Dự phòng khoản phải thu khó đòi  (*)', ' 5.Provision for bad loans', '139', '', '0.00', '0.00', '331', ' 1.Chi phí phải trả', ' 1.Payable cost', '335', '', '114107933.00', '114107933.00'),
(407, 'DNL', '99', '140*', 'IV.Hàng tồn kho', 'IV.Inventories', '15-159', '', '0.00', '0.00', '332', ' 2.Tài sản thừa chờ xử lý', ' 2.Surplus under pendency', '3381', '', '0.00', '0.00'),
(408, 'DNL', '99', '141', ' 1.Hàng mua đang đi trên đường', ' 1.Goods in transfer', '151', '', '0.00', '0.00', '333', ' 3.Nhận ký quỹ ,ký cược dài hạn', ' 3.Receipts of long-term deposits', '344', '', '0.00', '0.00'),
(409, 'DNL', '99', '142', ' 2.Nguyên liệu,vật liệu tồn kho', ' 2.Raw materials', '152', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(410, 'DNL', '99', '143', ' 3.Công cụ ,dung cụ trong kho', ' 3.Tools and intruments', '153', '', '0.00', '0.00', '400*', 'B.NGUỒN VỐN CHỦ SỞ HỮU', 'B.OWNER`S EQUITY', '4,412,413,421,431', '', '993655624.00', '993655624.00'),
(411, 'DNL', '99', '144', ' 4.Chi phí sản xuất KD dở dang', ' 4.Work in process', '154', '', '0.00', '0.00', '410*', 'I.Vốn - quỹ', 'I.Capital sourses and funds', '41-416,42,44,412,413,421', '', '993655624.00', '993655624.00'),
(412, 'DNL', '99', '145', ' 5.Thành phẩm tồn kho', ' 5.Finished products', '155', '', '0.00', '0.00', '411', ' 1.Vốn kinh doanh', ' 1.Business capital', '411', '', '849468096.00', '849468096.00'),
(413, 'DNL', '99', '146', ' 6.Hàng hoá tồn kho', ' 6.Goods in stock', '156', '', '0.00', '0.00', '412', ' 2.Chênh lệch đánh giá lại tài sản', ' 2.Differences of revaluation', '412', '', '0.00', '0.00'),
(414, 'DNL', '99', '147', ' 7.Hàng gửi đi bán', ' 7.Consigned goods for sale', '157', '', '0.00', '0.00', '413', ' 3.Chênh lệch tỷ giá', ' 3.Differences of exchange rate', '413', '', '0.00', '0.00'),
(415, 'DNL', '99', '149', ' 8.Dự phòng giãm giá hàng tồn kho (*)', ' 8.Provision for inventories', '159', '', '0.00', '0.00', '414', ' 4.Quỹ đầu tư phát triển', ' 4.Business development funds', '414', '', '24170780.00', '24170780.00'),
(416, 'DNL', '99', '150*', 'V.Tài sản lưu động khác', 'V.Other current assets', '14,1381', '', '0.00', '0.00', '415', ' 5.Quỹ dự phòng tài chính', ' 5.Reserved funds', '415,417,419', '', '0.00', '0.00'),
(417, 'DNL', '99', '151', ' 1.Tạm ứng', ' 1.Advances', '141', '', '0.00', '0.00', '416', ' 6.Lợi nhuận chưa phân phối', ' 6.Undestributed profit', '421', '', '-10688000.00', '-10688000.00'),
(418, 'DNL', '99', '152', ' 2.Chi phí trả trước', ' 2.Prepaid costs', '1421', '', '0.00', '0.00', '417', ' 7.Nguồn vốn đầu tư xây dựng cơ bản', ' 7.Capital investment sourses', '441', '', '92853580.00', '92853580.00'),
(419, 'DNL', '99', '153', ' 3.Chi phí chờ kết chuyển', ' 3.Pending costs for transfer', '1422', '', '0.00', '0.00', '420*', 'II.Nguồn kinh phí ,quỹ khác', 'II.Budget resources ,other funds', '45,46,416,431', '', '37851168.00', '37851168.00'),
(420, 'DNL', '99', '154', ' 4.Tài sản thiếu chờ xử lý', ' 4.Loss under pendency', '1381', '', '0.00', '0.00', '421', ' 1.Quỹ dự phòng trợ cấp mất việc', ' 1.Reserved funds', '416', '', '0.00', '0.00'),
(421, 'DNL', '99', '155', ' 5.Các khoản cầm cố,ký cược,ký quỹ NH', ' 5.Short-term mortgage and deposit', '144', '', '0.00', '0.00', '422', ' 2.Quỹ khen thưởng phúc lợi', ' 2.Reward and benifit funds', '431', '', '0.00', '0.00'),
(422, 'DNL', '99', '160*', 'VI.Chi sự nghiệp', 'VI.Administratvie', '161', '', '0.00', '0.00', '423', ' 3.Quỹ quản lý của cấp trên', ' 3.Management funds of higher level', '451', '', '0.00', '0.00'),
(423, 'DNL', '99', '161', ' 1.Chi sự nghiệp năm trước', ' 1.For previous year', '1611', '', '0.00', '0.00', '424', ' 4.Nguồn kinh phí sự nghiệp', ' 4.Administrative funds', '461', '', '0.00', '0.00'),
(424, 'DNL', '99', '162', ' 2.Chi sự nghiệp năm nay', ' 2.For current year', '1612', '', '0.00', '0.00', '425', '   - Nguồn kinh phí năm trước', '  - Of previous year', '4611', '', '0.00', '0.00'),
(425, 'DNL', '99', '200*', 'B.TÀI SẢN CỐ ĐỊNH & ĐẦU TƯ DÀI HẠN', 'B.FIXED ASSETS AND LONGTERM INVERST', '2-214-229', '', '0.00', '0.00', '426', '   - Nguồn kinh phí năm nay', '  - Of current year', '4612', '', '0.00', '0.00'),
(426, 'DNL', '99', '210*', 'I.Tài sản cố định', 'I.Fixed assets', '21-214', '', '0.00', '0.00', '427', ' 5.Nguồn kinh phí đã h/thành TSCĐ', ' 5.Administrative funds', '466', '', '0.00', '0.00'),
(427, 'DNL', '99', '211', ' 1.Tài sản cố định hữu hình', ' 1.Tangible fixed assets', '211,2141', '', '0.00', '0.00', '', '', '', '', '', '3055922840.00', '3055922840.00'),
(428, 'DNL', '99', '212', '   - Nguyên giá', '  - Original rate', '211', '', '0.00', '0.00', '430*', '       TỔNG CỘNG NGUỒN VỐN', '         TOTAL RESOURCES', '3,13-139,4,412,413,421,431,14', '', '0.00', '0.00'),
(429, 'DNL', '99', '213', '   - Giá trị hao mòn luỹ kế (*)', '  - Accumulated depreciation', '2141', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(430, 'DNL', '99', '214', ' 2.Tài sản cố định thuê tài chính', ' 2.Leased financial assets', '212,2142', '', '0.00', '0.00', '', '                  CÁC CHỈ TIÊU', '               ITEMS', '', '', '0.00', '0.00'),
(431, 'DNL', '99', '215', '   - Nguyên giá', '  - Original rate', '212', '', '0.00', '0.00', '', '    NGOÀI BẢNG CÂN ĐỐI KÊ TOÁN', '----------  INDICATORS ------------', '', '', '0.00', '0.00'),
(432, 'DNL', '99', '216', '   - Giá trị hao mòn luỹ kế (*)', '  - Accumulated depreciation', '2142', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(433, 'DNL', '99', '217', ' 3.Tài sản cố định vô hình', ' 1.Intangible fixed assets', '213,2143', '', '0.00', '0.00', '', ' 1.Tài sản thuê ngoài', '1.Leased assets from outside', '001', '', '0.00', '0.00'),
(434, 'DNL', '99', '218', '   - Nguyên giá', '  - Original rate', '213', '', '0.00', '0.00', '', ' 2.Vật tư hàng hoá giữ hộ,gia công', '2.Materials and goods entrusted for', '002', '', '0.00', '0.00'),
(435, 'DNL', '99', '219', '   - Giá trị hao mòn luỹ kế (*)', '  - Accumulated depreciation', '2143', '', '0.00', '0.00', '', ' 3.Hàng hoá nhận bán hộ ,ký gửi', '3.Goods to be consigned and depsite', '003', '', '0.00', '0.00'),
(436, 'DNL', '99', '220*', 'II.Các khoản đầu tư t/chính dài hạn', 'II.Long-term Financial investment', '22-229', '', '0.00', '0.00', '', ' 4.Nợ khó đòi đã xử lý', '4.Settled bad loans', '004', '', '0.00', '0.00'),
(437, 'DNL', '99', '221', ' 1.Đầu tư chứng khoán dài hạn', ' 1.Long-term securities', '221', '', '0.00', '0.00', '', ' 5.Ngoại tệ các loại', '5.Foreign currencies', '007', '', '0.00', '0.00'),
(438, 'DNL', '99', '222', ' 2.Góp vốn liên doanh', ' 2.Join-venture contribution', '222', '', '0.00', '0.00', '', '   -Tiền mặt Việt Nam', '  - vnd', '0071', '', '0.00', '0.00'),
(439, 'DNL', '99', '228', ' 3.Đầu tư dài hạn khác', ' 3.Others', '228', '', '0.00', '0.00', '', '   -...', '  - ...', '0072', '', '0.00', '0.00'),
(440, 'DNL', '99', '229', ' 4.Dự phòng giãm giá đầu tư dài hạn (*)', ' 4.Provision for devaluation', '229', '', '0.00', '0.00', '', '   -...', '  - ...', '0073', '', '0.00', '0.00'),
(441, 'DNL', '99', '230*', 'III.Chi phí xây dựng cơ bản dở dang', 'III.Cost for contruction in process', '241', '', '0.00', '0.00', '', ' 6.Hạn mức kinh phí còn lại', '6.Available depreciation amount', '008', '', '0.00', '0.00'),
(442, 'DNL', '99', '240*', 'IV.Các khoản ký quỹ,ký cược dài hạn', 'IV.Long-term deposits', '244', '', '0.00', '0.00', '', ' 7.Nguồn vốn kh/hao cơ bản hiện có', '7.Accumulated depreciation', '009', '', '0.00', '0.00'),
(443, 'DNL', '99', '241*', ' V.Chi phí trả trước dài hạn', ' V.Long-term Prepaid costs', '242', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(444, 'DNL', '99', '250*', '         TỔNG CỘNG TÀI SẢN', '            TOTAL ASSETS', '1-16-129-139-159,2-214-229,3', '', '0.00', '0.00', '', '     CỘNG TÀI SẢN NGOÀI BẢNG', '         TOTAL INDICATORS', '00', '', '0.00', '0.00'),
(445, 'DNL', '05', '100*', 'A - TÀI SẢN NGẮN HẠN (100) = 110+120+130+140+150', 'A - CURRENT ASSETS (100) = 110+120+130+140+150', '1-16-129-159-1319-139-1399-13619-13689-13889,33-335-3369-33889-3319', '', '0.00', '0.00', '300*', 'A - NỢ PHẢI TRẢ  (300 = 310 + 330)', 'A - LIABILITIES (300 = 310 + 330)', '3,13-139,14', '', '0.00', '0.00'),
(446, 'DNL', '05', '110*', 'I. Tiền và các khoản tương đương tiền', 'I. Cash and equivalentce', '11,12119,12129,12819,12889', '', '0.00', '0.00', '310*', 'I. Nợ ngắn hạn', 'I. Current liabilities', '31,33-3319-3369-3359-33889,352-3529,13-139-13619-13689-1319-13889,14', '', '0.00', '0.00'),
(447, 'DNL', '05', '111', '  1.Tiền', '  1.Cash', '11', 'V.01', '0.00', '0.00', '311', '  1. Vay và nợ ngắn hạn', '  1. Short-term loan and borrowing', '311,315', 'V.15', '0.00', '0.00'),
(448, 'DNL', '05', '112', '  2. Các khoản tương đương tiền', '  2. Cash equivalents', '12119,12129,12819,12889', '', '0.00', '0.00', '312', '  2. Phải trả người bán', '  2. Trade payables', '331-3319', '', '0.00', '0.00'),
(449, 'DNL', '05', '120*', 'II. Các khoản đầu tư tài chính ngắn hạn', 'II. Short-term financial investments', '12-129-12119-12129-12819-12889', 'V.02', '0.00', '0.00', '313', '  3. Người mua trả tiền trước', '  3. Advance from customers', '131-1319', '', '0.00', '0.00'),
(450, 'DNL', '05', '121', '  1. Đầu tư ngắn hạn', '  1. Short-term securities investments', '121-12119-12129,128-12819-12889', '', '0.00', '0.00', '314', '  4. Thuế và các khoản phải nộp Nhà nước', '  4. Taxes and payables to State Budget', '133,333', 'V.16', '0.00', '0.00'),
(451, 'DNL', '05', '129', '  2. Dự phòng giảm giá chứng khoán đầu tư ngắn hạn (*)', '  2. Provision for devaluation of short-term securities investment (*)', '129', '', '0.00', '0.00', '315', '  5. Phải trả người lao động', '  5. Payables to employees', '334', '', '0.00', '0.00'),
(452, 'DNL', '05', '130*', 'III. Các khoản phải thu', 'III. Account receivable', '13-133-1319-13619-13689-13889-139-1399,33-333-335-3369-33889-3319', '', '0.00', '0.00', '316', '  6. Chi phí phải trả', '  6. Accrued expenses', '335-3359', 'V.17', '0.00', '0.00'),
(453, 'DNL', '05', '131', '  1. Phải thu khách hàng', '  1. Trade receivable', '131-1319', '', '0.00', '0.00', '317', '  7. Phải trả nội bộ', '  7. Inter-company payables', '336-3369,136-13619-13689', '', '0.00', '0.00'),
(454, 'DNL', '05', '132', '  2. Trả trước cho người bán', '  2. Advances to suppliers', '331-3319', '', '0.00', '0.00', '318', '  8. Phải trả theo tiến độ kế hoạch HĐ xây dựng', '  8. Construction contracts in progress payables', '337', '', '0.00', '0.00'),
(455, 'DNL', '05', '133', '  3. Phải thu nội bộ ngắn hạn', '  3. Inter-company receivables', '136-13619-13689,336-3369', '', '0.00', '0.00', '319', '  9. Các khoản phải trả, phải nộp khác', '  9. Other payables', '338-33889,14,138-13889', 'V.18', '0.00', '0.00'),
(456, 'DNL', '05', '134', '  4. Phải thu theo tiến độ kế hoạch HĐ xây dựng', '  4. Construction contract in progress receiables', '337', '', '0.00', '0.00', '320', ' 10. Dự phòng phải trả ngắn hạn', ' 10. Provision for short-term payables', '352-3529', '', '0.00', '0.00'),
(457, 'DNL', '05', '135', '  5. Các khoản phải thu khác', '  5. Other receivables', '138-13889,338-33889,334', 'V.03', '0.00', '0.00', '330*', 'II. Nợ dài hạn', 'II. Long-term liabilities', '3319,3369,13619,13689,1319,13889,3359,33889,34,351,3529', '', '0.00', '0.00'),
(458, 'DNL', '05', '139', '  6. Dự phòng các khoản phải thu khó đòi (*)', '  6. Provision for doubtful debts (*)', '139-1399', '', '0.00', '0.00', '331', '  1. Phải trả dài hạn người bán', '  1. Long-term trade payables', '3319', '', '0.00', '0.00'),
(459, 'DNL', '05', '140*', 'IV. Hàng tồn kho', 'IV. Inventories', '15-159', '', '0.00', '0.00', '332', '  2. Phải trả dài hạn nội bộ', '  2. Long-term inter-company payables', '3369,13619,13689', 'V.19', '0.00', '0.00'),
(460, 'DNL', '05', '141', '  1. Hàng tồn kho', '  1. Inventories', '151,152,153,154,155,156,157,158', 'V.04', '0.00', '0.00', '333', '  3. Phải trả dài hạn khác', '  3. Other long-term payables', '1319,13889,3359,33889,344', '', '0.00', '0.00'),
(461, 'DNL', '05', '149', '  2. Dự phòng giảm giá hàng tồn kho (*)', '  2. Provision for inventories (*)', '159', '', '0.00', '0.00', '334', '  4. Vay và nợ dài hạn', '  4. Long-term loan and brrowings', '341,342,343', 'V.20', '0.00', '0.00'),
(462, 'DNL', '05', '150*', 'V. Tài sản ngắn hạn khác', 'V. Other current assets', '142,133,333,141,144', '', '0.00', '0.00', '335', '  5. Thuế thu nhập hoãn lại phải trả', '  5. Deferred income tax payables', '347', 'V.21', '0.00', '0.00'),
(463, 'DNL', '05', '151', '  1. Chi phí trả trước ngắn hạn', '  1. Prepaid expenses', '142', '', '0.00', '0.00', '336', '  6. Dự phòng trợ cấp mất việc làm', '  6. Provision for unemployment allowance', '351', '', '0.00', '0.00'),
(464, 'DNL', '05', '152', '  2. Thuế GTGT được khấu trừ', '  2. VAT deductibles', '133', '', '0.00', '0.00', '337', '  7. Dự phòng phải trả dài hạn', '  7. Provision for long-term payables', '3529', '', '0.00', '0.00'),
(465, 'DNL', '05', '154', '  3. Thuế và các khoản khác phải thu Nhà nước', '  3. Tax and receivables from budget', '333', 'V.05', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(466, 'DNL', '05', '158', '  4. Tài sản ngắn hạn khác', '  4. Other current assets', '141,144', '', '0.00', '0.00', '400*', 'B - VỐN CHỦ SỞ HỮU (400 = 410 + 430)', 'B - OWNER`S EQUITY (400 = 410 + 430)', '4,412,413,421,431,419,461', '', '0.00', '0.00'),
(467, 'DNL', '05', '', '', '', '', '', '0.00', '0.00', '410*', 'I. Vốn chủ sở hữu', 'I. Equity', '41,42,44,412,413,421,419', 'V.22', '0.00', '0.00'),
(468, 'DNL', '05', '200*', 'B - TÀI SẢN DÀI HẠN', 'B - NON-CURRENT ASSETS', '1319,3319,13619,13689,3369,13889,33889,1399,2-214-229', '', '0.00', '0.00', '411', '  1. Vốn đầu tư của chủ sở hữu', '  1. Paid-in capital', '4111', '', '0.00', '0.00'),
(469, 'DNL', '05', '', '  (200 = 210 + 220 + 240 + 250 + 260)', ' (200 = 210 + 220 + 240 + 250 + 260)', '', '', '0.00', '0.00', '412', '  2. Thặng dư vốn cổ phần', '  2. Paid-in capital in excess of par value', '4112', '', '0.00', '0.00'),
(470, 'DNL', '05', '210*', 'I- Các khoản phải thu dài hạn', 'I- Long-term receivables', '1319,3319,13619,13689,3369,13889,33889,1399,244', '', '0.00', '0.00', '413', '  3. Vốn khác của chủ sở hữu', '  3. Other padi-in capital', '4118', '', '0.00', '0.00'),
(471, 'DNL', '05', '211', '  1. Phải thu dài hạn của khách hàng', '  1. Long-term receivables - Trading', '1319,3319', '', '0.00', '0.00', '414', '  4. Cổ phiếu ngân quỹ (*)', '  4. Treasury stocks (*)', '419', '', '0.00', '0.00'),
(472, 'DNL', '05', '212', '  2. Vốn kinh doanh ở đơn vị trực thuộc', '  2. Capital in subsidiaries', '13619', '', '0.00', '0.00', '415', '  5. Chênh lệch đánh giá lại tài sản', '  5. Difference on revaluation of assets', '412', '', '0.00', '0.00'),
(473, 'DNL', '05', '213', '  3. Phải thu dài hạn nội bộ', '  3. Long-term inter-company receiables', '13689,3369', 'V.06', '0.00', '0.00', '416', '  6. Chênh lệch tỷ giá hối đoái', '  6. Foreign exchange difference', '413', '', '0.00', '0.00'),
(474, 'DNL', '05', '218', '  4. Phải thu dài hạn khác', '  4. Other long-term receivables', '13889,33889,244', 'V.07', '0.00', '0.00', '417', '  7. Quỹ đầu tư phát triển', '  7. Investment and Development fund', '414', '', '0.00', '0.00'),
(475, 'DNL', '05', '219', '  5. Dự phòng phải thu dài hạn khó đòi (*)', '  5. Provisions for long-term bad debts (*)', '1399', '', '0.00', '0.00', '418', '  8. Quỹ dự phòng tài chính', '  8. Financial reserve fund', '415', '', '0.00', '0.00'),
(476, 'DNL', '05', '220*', 'II. Tài sản cố định', 'II. Fixed assets', '21-217,241,2141,2142,2143', '', '0.00', '0.00', '419', '  9. Quỹ khác thuộc vốn chủ sở hữu', ' 9. Other funds', '418', '', '0.00', '0.00'),
(477, 'DNL', '05', '221', '  1. Tài sản cố định hữu hình', '  1. Tangible fixed assets', '211,2141', 'V.08', '0.00', '0.00', '420', '  10. Lợi nhuận sau thuế chưa phân phối', ' 10. Undistributed earnings', '421', '', '0.00', '0.00'),
(478, 'DNL', '05', '222', '      - Nguyên giá', '     - Historical cost', '211', '', '0.00', '0.00', '421', '  11. Nguồn vốn đầu tư XDCB', ' 11. Resources for capital expenditures', '441', '', '0.00', '0.00'),
(479, 'DNL', '05', '223', '      - Giá trị hao mòn lũy kế (*)', '     - Accumulated depreciation (*)', '2141', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(480, 'DNL', '05', '224', '  2. Tài sản cố định thuê tài chính', '  2. Financial lease assets', '212,2142', 'V.09', '0.00', '0.00', '430*', 'II. Nguồn kinh phí và quỹ khác', 'II. Subsidies and', '431,461,466', '', '0.00', '0.00'),
(481, 'DNL', '05', '225', '      - Nguyên giá', '     - Historical cost', '212', '', '0.00', '0.00', '431', '  1. Quỹ khen thưởng, phúc lợi', '  1. Bonus and welfare funds', '431', '', '0.00', '0.00'),
(482, 'DNL', '05', '226', '      - Giá trị hao mòn lũy kế (*)', '     - Accumulated depreciation (*)', '2142', '', '0.00', '0.00', '432', '  2. Nguồn kinh phí', '  2. Subsidy fund', '461', 'V.23', '0.00', '0.00'),
(483, 'DNL', '05', '227', '  3. Tài sản cố định vô hìình', '  3. Intangible assets', '213,2143', 'V.10', '0.00', '0.00', '433', '  3. Nguồn kinh phí đã hình thành TSCĐ', '  3. Funds used to acquire fixed assets', '466', '', '0.00', '0.00'),
(484, 'DNL', '05', '228', '      - Nguyên giá', '     - Historical cost', '213', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(485, 'DNL', '05', '229', '      - Giá trị hao mòn lũy kế (*)', '     - Accumulated depreciation (*)', '2143', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(486, 'DNL', '05', '230', '  4. Chi phí xây dựng cơ bản dở dang', '  4. Construction in progress', '241', 'V.11', '0.00', '0.00', '440*', 'TỔNG CỘNG NGUỒN VỐN (440 = 300 + 400)', 'TOTAL RESOURCE (440 = 300 + 400)', '3,13-139,14,4,412,413,421,431,419,461', '', '0.00', '0.00'),
(487, 'DNL', '05', '240*', 'III. Bất động sản đầu tư', 'III. Real eatate investment', '217,2147', 'V.12', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(488, 'DNL', '05', '241', '      - Nguyên giá', '     - Historical cost', '217', '', '0.00', '0.00', '', '                 CÁC CHỈ TIÊU', '  OFF BALANCE SHEET ITEMS', '', '', '0.00', '0.00'),
(489, 'DNL', '05', '242', '      - Giá trị hao mòn lũy kế (*)', '     - Accumulated depreciation (*)', '2147', '', '0.00', '0.00', '', '   NGOÀI BẢNG CÂN ĐỐI KÊ TOÁN', '', '', '', '0.00', '0.00'),
(490, 'DNL', '05', '250*', 'IV. Các khoản đầu tư tài chính dài hạn', 'IV. Long-term financial investment', '22-229', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(491, 'DNL', '05', '251', '  1. Đầu tư vào công ty con', '  1. Investment in subsidiaries', '221', '', '0.00', '0.00', '', '  1. Tài sản thuê ngoài', '  1. Operating lease assets', '001', 'V.24', '0.00', '0.00'),
(492, 'DNL', '05', '252', '  2. Đầu tư vào công ty liên kết, liên doanh', '  2. Investment in associates and interest in Joint Ventures', '222,223', '', '0.00', '0.00', '', '  2. Vật tư, hàng hóa nhận giữ hộ, nhận gia công', '  2. Goods held under trust or for processing', '002', '', '0.00', '0.00'),
(493, 'DNL', '05', '258', '  3. Đầu tư dài hạn khác', '  3. Other long-term investment', '228', 'V.13', '0.00', '0.00', '', '  3. Hàng hóa nhận bán hộ, nhận ký gửi ,ký cược', '  3. Goods received', '003', '', '0.00', '0.00'),
(494, 'DNL', '05', '259', '  4. Dự phòng giảm giá chứng khoán đầu tư dài hạn (*)', '  4. Provision for devaluation of long-term securities investment (*)', '229', '', '0.00', '0.00', '', '  4. Nợ khó đòi đã xử lý', '  4. Bad debts written off', '004', '', '0.00', '0.00'),
(495, 'DNL', '05', '260*', 'V. Tài sản dài hạn khác', 'V. Other long-term assets', '242,243', '', '0.00', '0.00', '', '  5. Ngoại tệ các loại', '  5. Foreign currencies', '007', '', '0.00', '0.00'),
(496, 'DNL', '05', '261', '  1. Chi phí trả trước dài hạn', '  1. Long-term prepayment', '242', 'V.14', '0.00', '0.00', '', '    - USD', '    - USD', '0071', '', '0.00', '0.00'),
(497, 'DNL', '05', '262', '  2. Tài sản thuế thu nhập hoãn lại', '  2. Deferred income tax assets', '243', 'V.21', '0.00', '0.00', '', '    - ....', '    - ....', '0072', '', '0.00', '0.00'),
(498, 'DNL', '05', '268', '  3. Tài sản dài hạn khác', '  3. Other long-term assets', '', '', '0.00', '0.00', '', '  6. Dự toán chi sự nghiệp ,dự án', '  6. Remaining budget', '008', '', '0.00', '0.00'),
(499, 'DNL', '05', '', '', '', '', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(500, 'DNL', '05', '270*', 'TỔNG CỘNG TÀI SẢN  (270 = 100 + 200)', 'TOTAL ASSETS (270 = 100 + 200)', '1-16-129-139-159,2-214-229,33-335', '', '0.00', '0.00', '   *', '   CỘNG TÀI SẢN NGOÀI BẢNG', ' TOTAL OFF BALANCE SHEET', '00', '', '0.00', '0.00'),
(501, 'DNL', '10', '100*', 'A - TÀI SẢN NGẮN HẠN (100) = 110+120+130+140+150', 'A - CURRENT ASSETS (100) = 110+120+130+140+150', '1-16-129-159-1319-139-1399-13619-13689-13889,33-335-3369-33889-3319,35', '', '0.00', '0.00', '300*', 'A - NỢ PHẢI TRẢ  (300 = 310 + 330)', 'A - LIABILITIES (300 = 310 + 330)', '3,13-139,14,431', '', '0.00', '0.00'),
(502, 'DNL', '10', '110*', 'I. Tiền và các khoản tương đương tiền', 'I. Cash and equivalentce', '11,12119,12129,12819,12889', '', '0.00', '0.00', '310*', 'I. Nợ ngắn hạn', 'I. Current liabilities', '31,33-3319-3369-3359-33889-3387,353,431,352-3529,13-139-13619-13689-1319-13889,1', '', '0.00', '0.00'),
(503, 'DNL', '10', '111', '  1.Tiền', '  1.Cash', '11', 'V.01', '0.00', '0.00', '311', '  1. Vay và nợ ngắn hạn', '  1. Short-term loan and borrowing', '311,315', 'V.15', '0.00', '0.00'),
(504, 'DNL', '10', '112', '  2. Các khoản tương đương tiền', '  2. Cash equivalents', '12119,12129,12819,12889', '', '0.00', '0.00', '312', '  2. Phải trả người bán', '  2. Trade payables', '331-3319', '', '0.00', '0.00'),
(505, 'DNL', '10', '120*', 'II. Các khoản đầu tư tài chính ngắn hạn', 'II. Short-term financial investments', '12-129-12119-12129-12819-12889', 'V.02', '0.00', '0.00', '313', '  3. Người mua trả tiền trước', '  3. Advance from customers', '131-1319', '', '0.00', '0.00'),
(506, 'DNL', '10', '121', '  1. Đầu tư ngắn hạn', '  1. Short-term securities investments', '121-12119-12129,128-12819-12889', '', '0.00', '0.00', '314', '  4. Thuế và các khoản phải nộp Nhà nước', '  4. Taxes and payables to State Budget', '133,333', 'V.16', '0.00', '0.00'),
(507, 'DNL', '10', '129', '  2. Dự phòng giảm giá chứng khoán đầu tư ngắn hạn (*)', '  2. Provision for devaluation of short-term securities investment (*)', '129', '', '0.00', '0.00', '315', '  5. Phải trả người lao động', '  5. Payables to employees', '334', '', '0.00', '0.00'),
(508, 'DNL', '10', '130*', 'III. Các khoản phải thu', 'III. Account receivable', '13-133-1319-13619-13689-13889-139-1399,33-333-335-3369-33889-3319,35', '', '0.00', '0.00', '316', '  6. Chi phí phải trả', '  6. Accrued expenses', '335-3359', 'V.17', '0.00', '0.00'),
(509, 'DNL', '10', '131', '  1. Phải thu khách hàng', '  1. Trade receivable', '131-1319', '', '0.00', '0.00', '317', '  7. Phải trả nội bộ', '  7. Inter-company payables', '336-3369,136-13619-13689', '', '0.00', '0.00'),
(510, 'DNL', '10', '132', '  2. Trả trước cho người bán', '  2. Advances to suppliers', '331-3319', '', '0.00', '0.00', '318', '  8. Phải trả theo tiến độ kế hoạch HĐ xây dựng', '  8. Construction contracts in progress payables', '337', '', '0.00', '0.00'),
(511, 'DNL', '10', '133', '  3. Phải thu nội bộ ngắn hạn', '  3. Inter-company receivables', '136-13619-13689,336-3369', '', '0.00', '0.00', '319', '  9. Các khoản phải trả, phải nộp khác', '  9. Other payables', '338-33889-3387,14,138-13889', 'V.18', '0.00', '0.00'),
(512, 'DNL', '10', '134', '  4. Phải thu theo tiến độ kế hoạch HĐ xây dựng', '  4. Construction contract in progress receiables', '337', '', '0.00', '0.00', '320', ' 10. Dự phòng phải trả ngắn hạn', ' 10. Provision for short-term payables', '352-3529', '', '0.00', '0.00'),
(513, 'DNL', '10', '135', '  5. Các khoản phải thu khác', '  5. Other receivables', '138-13889,338-33889,334,35', 'V.03', '0.00', '0.00', '323', ' 11. Quỹ khen thưởng, phúc lợi', ' 11. Bonus and welfare funds', '353,431', '', '0.00', '0.00'),
(514, 'DNL', '10', '139', '  6. Dự phòng các khoản phải thu khó đòi (*)', '  6. Provision for doubtful debts (*)', '139-1399', '', '0.00', '0.00', '330*', 'II. Nợ dài hạn', 'II. Long-term liabilities', '3319,3369,13619,13689,1319,13889,3359,33889,34,351,3529,3387,356', '', '0.00', '0.00'),
(515, 'DNL', '10', '', '', '', '', '', '0.00', '0.00', '331', '  1. Phải trả dài hạn người bán', '  1. Long-term trade payables', '3319', '', '0.00', '0.00'),
(516, 'DNL', '10', '140*', 'IV. Hàng tồn kho', 'IV. Inventories', '15-159', '', '0.00', '0.00', '332', '  2. Phải trả dài hạn nội bộ', '  2. Long-term inter-company payables', '3369,13619,13689', 'V.19', '0.00', '0.00'),
(517, 'DNL', '10', '141', '  1. Hàng tồn kho', '  1. Inventories', '151,152,153,154,155,156,157,158', 'V.04', '0.00', '0.00', '333', '  3. Phải trả dài hạn khác', '  3. Other long-term payables', '1319,13889,3359,33889,344', '', '0.00', '0.00'),
(518, 'DNL', '10', '149', '  2. Dự phòng giảm giá hàng tồn kho (*)', '  2. Provision for inventories (*)', '159', '', '0.00', '0.00', '334', '  4. Vay và nợ dài hạn', '  4. Long-term loan and brrowings', '341,342,343', 'V.20', '0.00', '0.00'),
(519, 'DNL', '10', '150*', 'V. Tài sản ngắn hạn khác', 'V. Other current assets', '142,133,333,141,144', '', '0.00', '0.00', '335', '  5. Thuế thu nhập hoãn lại phải trả', '  5. Deferred income tax payables', '347', 'V.21', '0.00', '0.00'),
(520, 'DNL', '10', '151', '  1. Chi phí trả trước ngắn hạn', '  1. Prepaid expenses', '142', '', '0.00', '0.00', '336', '  6. Dự phòng trợ cấp mất việc làm', '  6. Provision for unemployment allowance', '351', '', '0.00', '0.00'),
(521, 'DNL', '10', '152', '  2. Thuế GTGT được khấu trừ', '  2. VAT deductibles', '133', '', '0.00', '0.00', '337', '  7. Dự phòng phải trả dài hạn', '  7. Provision for long-term payables', '3529', '', '0.00', '0.00'),
(522, 'DNL', '10', '154', '  3. Thuế và các khoản khác phải thu Nhà nước', '  3. Tax and receivables from budget', '333', 'V.05', '0.00', '0.00', '338', '  8. Doanh thu chưa thực hiện', '  8. Doanh thu chŸa th¨c hi¬n', '3387', '', '0.00', '0.00'),
(523, 'DNL', '10', '158', '  4. Tài sản ngắn hạn khác', '  4. Other current assets', '141,144', '', '0.00', '0.00', '339', '  9. Quỹ phát triển Khoa học và Công nghệ', '  9. Quñ ph t triŽn Khoa h”c v… C“ng ngh¬', '356', '', '0.00', '0.00'),
(524, 'DNL', '10', '', '', '', '', '', '0.00', '0.00', '400*', 'B - VỐN CHỦ SỞ HỮU (400 = 410 + 430)', 'B - OWNER`S EQUITY (400 = 410 + 430)', '4-431,412,413,421,419,461', '', '0.00', '0.00'),
(525, 'DNL', '10', '', '', '', '', '', '0.00', '0.00', '410*', 'I. Vốn chủ sở hữu', 'I. Equity', '41-431,42,44,412,413,421,419', 'V.22', '0.00', '0.00'),
(526, 'DNL', '10', '200*', 'B - TÀI SẢN DÀI HẠN', 'B - NON-CURRENT ASSETS', '1319,3319,13619,13689,3369,13889,33889,1399,2-214-229', '', '0.00', '0.00', '411', '  1. Vốn đầu tư của chủ sở hữu', '  1. Paid-in capital', '4111', '', '0.00', '0.00'),
(527, 'DNL', '10', '', '  (200 = 210 + 220 + 240 + 250 + 260)', ' (200 = 210 + 220 + 240 + 250 + 260)', '', '', '0.00', '0.00', '412', '  2. Thặng dư vốn cổ phần', '  2. Paid-in capital in excess of par value', '4112', '', '0.00', '0.00'),
(528, 'DNL', '10', '210*', 'I- Các khoản phải thu dài hạn', 'I- Long-term receivables', '1319,3319,13619,13689,3369,13889,33889,1399,244', '', '0.00', '0.00', '413', '  3. Vốn khác của chủ sở hữu', '  3. Other padi-in capital', '4118', '', '0.00', '0.00'),
(529, 'DNL', '10', '211', '  1. Phải thu dài hạn của khách hàng', '  1. Long-term receivables - Trading', '1319,3319', '', '0.00', '0.00', '414', '  4. Cổ phiếu ngân quỹ (*)', '  4. Treasury stocks (*)', '419', '', '0.00', '0.00'),
(530, 'DNL', '10', '212', '  2. Vốn kinh doanh ở đơn vị trực thuộc', '  2. Capital in subsidiaries', '13619', '', '0.00', '0.00', '415', '  5. Chênh lệch đánh giá lại tài sản', '  5. Difference on revaluation of assets', '412', '', '0.00', '0.00'),
(531, 'DNL', '10', '213', '  3. Phải thu dài hạn nội bộ', '  3. Long-term inter-company receiables', '13689,3369', 'V.06', '0.00', '0.00', '416', '  6. Chênh lệch tỷ giá hối đoái', '  6. Foreign exchange difference', '413', '', '0.00', '0.00'),
(532, 'DNL', '10', '218', '  4. Phải thu dài hạn khác', '  4. Other long-term receivables', '13889,33889,244', 'V.07', '0.00', '0.00', '417', '  7. Quỹ đầu tư phát triển', '  7. Investment and Development fund', '414', '', '0.00', '0.00'),
(533, 'DNL', '10', '219', '  5. Dự phòng phải thu dài hạn khó đòi (*)', '  5. Provisions for long-term bad debts (*)', '1399', '', '0.00', '0.00', '418', '  8. Quỹ dự phòng tài chính', '  8. Financial reserve fund', '415', '', '0.00', '0.00'),
(534, 'DNL', '10', '220*', 'II. Tài sản cố định', 'II. Fixed assets', '21-217,241,2141,2142,2143', '', '0.00', '0.00', '419', '  9. Quỹ khác thuộc vốn chủ sở hữu', ' 9. Other funds', '418', '', '0.00', '0.00'),
(535, 'DNL', '10', '221', '  1. Tài sản cố định hữu hình', '  1. Tangible fixed assets', '211,2141', 'V.08', '0.00', '0.00', '420', '  10. Lợi nhuận sau thuế chưa phân phối', ' 10. Undistributed earnings', '421', '', '0.00', '0.00'),
(536, 'DNL', '10', '222', '      - Nguyên giá', '     - Historical cost', '211', '', '0.00', '0.00', '421', '  11. Nguồn vốn đầu tư XDCB', ' 11. Resources for capital expenditures', '441', '', '0.00', '0.00'),
(537, 'DNL', '10', '223', '      - Giá trị hao mòn lũy kế (*)', '     - Accumulated depreciation (*)', '2141', '', '0.00', '0.00', '422', '  12. Quỹ hổ trợ sắp xếp doanh nghiệp', ' 12. Quñ h™ trø sép x‰p doanh nghi¬p', '417', '', '0.00', '0.00'),
(538, 'DNL', '10', '224', '  2. Tài sản cố định thuê tài chính', '  2. Financial lease assets', '212,2142', 'V.09', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(539, 'DNL', '10', '225', '      - Nguyên giá', '     - Historical cost', '212', '', '0.00', '0.00', '430*', 'II. Nguồn kinh phí', 'II. Subsidies and', '461,466', '', '0.00', '0.00'),
(540, 'DNL', '10', '226', '      - Giá trị hao mòn lũy kế (*)', '     - Accumulated depreciation (*)', '2142', '', '0.00', '0.00', '432', '  2. Nguồn kinh phí', '  2. Subsidy fund', '461', 'V.23', '0.00', '0.00'),
(541, 'DNL', '10', '227', '  3. Tài sản cố định vô hìình', '  3. Intangible assets', '213,2143', 'V.10', '0.00', '0.00', '433', '  3. Nguồn kinh phí đã hình thành TSCĐ', '  3. Funds used to acquire fixed assets', '466', '', '0.00', '0.00'),
(542, 'DNL', '10', '228', '      - Nguyên giá', '     - Historical cost', '213', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(543, 'DNL', '10', '229', '      - Giá trị hao mòn lũy kế (*)', '     - Accumulated depreciation (*)', '2143', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(544, 'DNL', '10', '230', '  4. Chi phí xây dựng cơ bản dở dang', '  4. Construction in progress', '241', 'V.11', '0.00', '0.00', '440*', 'TỔNG CỘNG NGUỒN VỐN (440 = 300 + 400)', 'TOTAL RESOURCE (440 = 300 + 400)', '3,13-139,14,4,412,413,421,431,419,461', '', '0.00', '0.00'),
(545, 'DNL', '10', '240*', 'III. Bất động sản đầu tư', 'III. Real eatate investment', '217,2147', 'V.12', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(546, 'DNL', '10', '241', '      - Nguyên giá', '     - Historical cost', '217', '', '0.00', '0.00', '', '                 CÁC CHỈ TIÊU', '   OFF BALANCE SHEET ITEMS', '', '', '0.00', '0.00'),
(547, 'DNL', '10', '242', '      - Giá trị hao mòn lũy kế (*)', '     - Accumulated depreciation (*)', '2147', '', '0.00', '0.00', '', '   NGOÀI BẢNG CÂN ĐỐI KÊ TOÁN', '', '', '', '0.00', '0.00'),
(548, 'DNL', '10', '250*', 'IV. Các khoản đầu tư tài chính dài hạn', 'IV. Long-term financial investment', '22-229', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(549, 'DNL', '10', '251', '  1. Đầu tư vào công ty con', '  1. Investment in subsidiaries', '221', '', '0.00', '0.00', '', '  1. Tài sản thuê ngoài', '  1. Operating lease assets', '001', 'V.24', '0.00', '0.00'),
(550, 'DNL', '10', '252', '  2. Đầu tư vào công ty liên kết, liên doanh', '  2. Investment in associates and interest in Joint Ventures', '222,223', '', '0.00', '0.00', '', '  2. Vật tư, hàng hóa nhận giữ hộ, nhận gia công', '  2. Goods held under trust or for processing', '002', '', '0.00', '0.00'),
(551, 'DNL', '10', '258', '  3. Đầu tư dài hạn khác', '  3. Other long-term investment', '228', 'V.13', '0.00', '0.00', '', '  3. Hàng hóa nhận bán hộ, nhận ký gửi ,ký cược', '  3. Goods received', '003', '', '0.00', '0.00'),
(552, 'DNL', '10', '259', '  4. Dự phòng giảm giá chứng khoán đầu tư dài hạn (*)', '  4. Provision for devaluation of long-term securities investment (*)', '229', '', '0.00', '0.00', '', '  4. Nợ khó đòi đã xử lý', '  4. Bad debts written off', '004', '', '0.00', '0.00'),
(553, 'DNL', '10', '260*', 'V. Tài sản dài hạn khác', 'V. Other long-term assets', '242,243', '', '0.00', '0.00', '', '  5. Ngoại tệ các loại', '  5. Foreign currencies', '007', '', '0.00', '0.00'),
(554, 'DNL', '10', '261', '  1. Chi phí trả trước dài hạn', '  1. Long-term prepayment', '242', 'V.14', '0.00', '0.00', '', '    - USD', '    - USD', '0071', '', '0.00', '0.00'),
(555, 'DNL', '10', '262', '  2. Tài sản thuế thu nhập hoãn lại', '  2. Deferred income tax assets', '243', 'V.21', '0.00', '0.00', '', '    - ....', '    - ....', '0072', '', '0.00', '0.00'),
(556, 'DNL', '10', '268', '  3. Tài sản dài hạn khác', '  3. Other long-term assets', '', '', '0.00', '0.00', '', '  6. Dự toán chi sự nghiệp ,dự án', '  6. Remaining budget', '008', '', '0.00', '0.00'),
(557, 'DNL', '10', '', '', '', '', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(558, 'DNL', '10', '270*', 'TỔNG CỘNG TÀI SẢN  (270 = 100 + 200)', 'TOTAL ASSETS (270 = 100 + 200)', '1-16-129-139-159,2-214-229,33-335,35', '', '0.00', '0.00', '   *', '   CỘNG TÀI SẢN NGOÀI BẢNG', ' TOTAL OFF BALANCE SHEET', '00', '', '0.00', '0.00'),
(559, 'DNL', '15', '100**', 'A - TÀI SẢN NGẮN HẠN (100) = 110+120+130+140+150', 'A - CURRENT ASSETS (100) = 110+120+130+140+150', '110+120+130+140+150', '', '9.00', '0.00', '300**', 'C - NỢ PHẢI TRẢ  (300 = 310 + 330)', 'A - LIABILITIES (300 = 310 + 330)', '310+330', '', '0.00', '0.00'),
(560, 'DNL', '15', '110*', 'I. Tiền và các khoản tương đương tiền', 'I. Cash and equivalentce', '111+112', '', '3.00', '0.00', '310*', 'I. Nợ ngắn hạn', 'I. Current liabilities', '311+312+313+314+315+316+317+318+319+320+321+322+323+324', '', '0.00', '0.00'),
(561, 'DNL', '15', '111', '  1.Tiền', '  1.Cash', '111,112', 'V.01', '1.00', '0.00', '311', '  1. Phải trả người bán ngắn hạn', '  2. Trade payables', '331-3319', 'V.15', '0.00', '0.00'),
(562, 'DNL', '15', '112', '  2. Các khoản tương đương tiền', '  2. Cash equivalents', '113', '', '2.00', '0.00', '312', '  2. Người mua trả tiền trước ngắn hạn', '  3. Advance from customers', '131-1319', '', '0.00', '0.00'),
(563, 'DNL', '15', '120*', 'II. Đầu tư tài chính ngắn hạn', 'II. Short-term financial investments', '121+122+123', 'V.02', '4.00', '0.00', '313', '  3. Thuế và các khoản phải nộp Nhà nước', '  4. Taxes and payables to State Budget', '133,333', '', '0.00', '0.00'),
(564, 'DNL', '15', '121', '  1. Chứng khoán kinh doanh', '  1. Short-term securities investments', '121', '', '3.00', '0.00', '314', '  4. Phải trả người lao động', '  5. Payables to employees', '334', 'V.16', '0.00', '0.00'),
(565, 'DNL', '15', '122', '  2. Dự phòng giảm giá Chứng khoán kinh doanh (*)', '  2. Provision for devaluation of short-term securities investment (*)', '2291', '', '1.00', '0.00', '315', '  5. Chi phí phải trả ngắn hạn', '  6. Accrued expenses', '335-3359', '', '0.00', '0.00'),
(566, 'DNL', '15', '123', '  3. Đầu tư nắm giữ đến ngày đáo hạn', '', '1281-12819,1282-12829,1288-12889', '', '0.00', '0.00', '316', '  6. Phải trả nội bộ ngắn hạn', '  7. Inter-company payables', '336-3361-33689,136-13689', '', '0.00', '0.00');
INSERT INTO `cdketoan` (`id`, `chedokt`, `kyhieu`, `masc`, `tentsc`, `tentscu`, `tk1`, `tmtsc`, `tscd`, `tscc`, `masn`, `tentsn`, `tentsnu`, `tk2`, `tmtsn`, `tsnd`, `tsnc`) VALUES
(567, 'DNL', '15', '130*', 'III. Các khoản phải thu ngắn hạn', 'III. Account receivable', '131+132+133+134+135+136+137+139', '', '1.00', '0.00', '317', '  7. Phải trả theo tiến độ kế hoạch HĐ xây dựng', '  8. Construction contracts in progress payables', '337', 'V.17', '0.00', '0.00'),
(568, 'DNL', '15', '131', '  1. Phải thu ngắn hạn của khách hàng', '  1. Trade receivable', '131-1319', '', '0.00', '0.00', '318', '  8. Doanh thu chưa thực hiện ngắn hạn', '', '3387-33879', '', '0.00', '0.00'),
(569, 'DNL', '15', '132', '  2. Trả trước cho người bán ngắn hạn', '  2. Advances to suppliers', '331-3319', '', '1.00', '0.00', '319', '  9. Phải trả ngắn hạn  khác', '  9. Other payables', '338-33889-3387,138-13889,14', '', '0.00', '0.00'),
(570, 'DNL', '15', '133', '  3. Phải thu nội bộ ngắn hạn', '  3. Inter-company receivables', '136-1361-13689,336-33689', '', '0.00', '0.00', '320', ' 10. Vay và nợ thuê tài chính ngắn hạn', '', '341-34119-34129', 'V.18', '0.00', '0.00'),
(571, 'DNL', '15', '134', '  4. Phải thu theo tiến độ kế hoạch HĐ xây dựng', '  4. Construction contract in progress receiables', '337', '', '0.00', '0.00', '321', ' 11. Dự phòng phải trả ngắn hạn', ' 10. Provision for short-term payables', '352-3529', '', '0.00', '0.00'),
(572, 'DNL', '15', '135', '  5. Phải thu về cho vay ngắn hạn', '', '1283-12839', '', '0.00', '0.00', '322', ' 12. Quỹ khen thưởng, phúc lợi', ' 11. Bonus and welfare funds', '353', '', '0.00', '0.00'),
(573, 'DNL', '15', '136', '  6. Phải thu ngắn hạn khác', '  5. Other receivables', '1380,1385,1388-13889,338-33889,334,352,356,357,341', 'V.03', '0.00', '0.00', '323', ' 13. Quỹ bình ổn giá', '', '357', '', '0.00', '0.00'),
(574, 'DNL', '15', '137', '  7. Dự phòng phải thu ngắn hạn khó đòi (*)', '  6. Provision for doubtful debts (*)', '2293-22939', '', '0.00', '0.00', '324', ' 14. Giao dịch mua bán lại trái phiếu Chính phủ', '', '171', '', '0.00', '0.00'),
(575, 'DNL', '15', '139', '  8. Tài sản thiếu chờ xử lý', '', '1381', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(576, 'DNL', '15', '140*', 'IV. Hàng tồn kho', 'IV. Inventories', '141+149', '', '1.00', '0.00', '', '', '', '', 'V.19', '0.00', '0.00'),
(577, 'DNL', '15', '141', '  1. Hàng tồn kho', '  1. Inventories', '15-1549-15349', 'V.04', '1.00', '0.00', '330*', 'II. Nợ dài hạn', 'II. Long-term liabilities', '331+332+333+334+335+336+337+338+339+340+341+342+343', '', '0.00', '0.00'),
(578, 'DNL', '15', '149', '  2. Dự phòng giảm giá hàng tồn kho (*)', '  2. Provision for inventories (*)', '2294', '', '0.00', '0.00', '331', '  1. Phải trả người bán dài hạn', '  1. Long-term trade payables', '3319', 'V.20', '0.00', '0.00'),
(579, 'DNL', '15', '150*', 'V. Tài sản ngắn hạn khác', 'V. Other current assets', '151+152+153+154+155', '', '0.00', '0.00', '332', '  2. Người mua trả tiền trước dài hạn', '', '1319', 'V.21', '0.00', '0.00'),
(580, 'DNL', '15', '151', '  1. Chi phí trả trước ngắn hạn', '  1. Prepaid expenses', '242-2429', '', '0.00', '0.00', '333', '  3. Chi phí phải trả dài hạn', '', '3359', '', '0.00', '0.00'),
(581, 'DNL', '15', '152', '  2. Thuế GTGT được khấu trừ', '  2. VAT deductibles', '133', '', '0.00', '0.00', '334', '  4. Phải trả nội bộ về vốn kinh doanh', '', '3361', '', '0.00', '0.00'),
(582, 'DNL', '15', '153', '  3. Thuế và các khoản khác phải thu Nhà nước', '  3. Tax and receivables from budget', '333', 'V.05', '0.00', '0.00', '335', '  5. Phải trả nội bộ dài hạn', '  2. Long-term inter-company payables', '33689,13689', '', '0.00', '0.00'),
(583, 'DNL', '15', '154', '  4. Giao dịch mua bán lại trái phiếu Chính phủ', '', '171', '', '0.00', '0.00', '336', '  6. Doanh thu chưa thực hiện dài hạn', '', '33879', '', '0.00', '0.00'),
(584, 'DNL', '15', '155', '  5. Tài sản ngắn hạn khác', '  4. Other current assets', '14,335', '', '0.00', '0.00', '337', '  7. Phải trả dài hạn khác', '  3. Other long-term payables', '13889,33889,344', '', '0.00', '0.00'),
(585, 'DNL', '15', '', '', '', '', '', '0.00', '0.00', '338', '  8. Vay và nợ thuê tài chính dài hạn', '  4. Long-term loan and brrowings', '34119,34129', 'V.22', '0.00', '0.00'),
(586, 'DNL', '15', '200**', 'B - TÀI SẢN DÀI HẠN', 'B - NON-CURRENT ASSETS', '210+220+230+240+250+260', '', '2.00', '0.00', '339', '  9. Trái phiếu chuyển đổi', '', '343', '', '0.00', '0.00'),
(587, 'DNL', '15', '', '  (200 = 210 + 220 + 240 + 250 + 260)', ' (200 = 210 + 220 + 240 + 250 + 260)', '', '', '0.00', '0.00', '340', ' 10. Cổ phiếu ưu đãi', '', '', '', '0.00', '0.00'),
(588, 'DNL', '15', '210*', 'I- Các khoản phải thu dài hạn', 'I- Long-term receivables', '211+212+213+214+215+216+219', '', '2.00', '0.00', '341', ' 11. Thuế thu nhập hoãn lại phải trả', '  5. Deferred income tax payables', '347', '', '0.00', '0.00'),
(589, 'DNL', '15', '211', '  1. Phải thu dài hạn của khách hàng', '  1. Long-term receivables - Trading', '1319', '', '0.00', '0.00', '342', ' 12. Dự phòng phải trả dài hạn', '  7. Provision for long-term payables', '3529', '', '0.00', '0.00'),
(590, 'DNL', '15', '212', '  2. Trả trước cho người  bán dài hạn', '', '3319', '', '2.00', '0.00', '343', ' 13. Quỹ phát triển Khoa học và Công nghệ', '', '356', '', '0.00', '0.00'),
(591, 'DNL', '15', '213', '  3. Vốn kinh doanh ở đơn vị trực thuộc', '  2. Capital in subsidiaries', '1361', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(592, 'DNL', '15', '214', '  4. Phải thu nội bộ dài hạn', '  3. Long-term inter-company receiables', '13689,33689', 'V.06', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(593, 'DNL', '15', '215', '  5. Phải thu về cho vay dài hạn', '', '12839', '', '0.00', '0.00', '400**', 'D - VỐN CHỦ SỞ HỮU (400 = 410 + 430)', 'B - OWNER`S EQUITY (400 = 410 + 430)', '410+430', '', '0.00', '0.00'),
(594, 'DNL', '15', '216', '  6. Phải thu dài hạn khác', '  4. Other long-term receivables', '13889,33889', 'V.07', '0.00', '0.00', '410*', 'I. Vốn chủ sở hữu', 'I. Equity', '411+412+413+414+415+416+417+418+419+420+421+422', '', '0.00', '0.00'),
(595, 'DNL', '15', '219', '  7. Dự phòng phải thu dài hạn khó đòi (*)', '  5. Provisions for long-term bad debts (*)', '22939', '', '0.00', '0.00', '411', '  1. Vốn góp của chủ sở hữu', '  1. Equity', '4111', '', '0.00', '0.00'),
(596, 'DNL', '15', '220*', 'II. Tài sản cố định', 'II. Fixed assets', '221+224+227', '', '0.00', '0.00', '411a', '      - Cổ phiếu phổ thông có quyền biểu quyết', '', '41111', '', '0.00', '0.00'),
(597, 'DNL', '15', '221', '  1. Tài sản cố định hữu hình', '  1. Tangible fixed assets', '211,2141', 'V.08', '0.00', '0.00', '411b', '      - Cổ phiếu ưu đãi', '', '41112', '', '0.00', '0.00'),
(598, 'DNL', '15', '222', '      - Nguyên giá', '     - Historical cost', '211', '', '0.00', '0.00', '412', '  2. Thặng dư vốn cổ phần', '  2. Paid-in capital in excess of par value', '4112', '', '0.00', '0.00'),
(599, 'DNL', '15', '223', '      - Giá trị hao mòn lũy kế (*)', '     - Accumulated depreciation (*)', '2141', '', '0.00', '0.00', '413', '  3. Quyền chọn chuyển đổi trái phiếu', '', '4113', '', '0.00', '0.00'),
(600, 'DNL', '15', '224', '  2. Tài sản cố định thuê tài chính', '  2. Financial lease assets', '212,2142', 'V.09', '0.00', '0.00', '414', '  4. Vốn khác của chủ sở hữu', '  3. Other padi-in capital', '4118', '', '0.00', '0.00'),
(601, 'DNL', '15', '225', '      - Nguyên giá', '     - Historical cost', '212', '', '0.00', '0.00', '415', '  5. Cổ phiếu quỹ (*)', '  4. Treasury stocks (*)', '419', '', '0.00', '0.00'),
(602, 'DNL', '15', '226', '      - Giá trị hao mòn lũy kế (*)', '     - Accumulated depreciation (*)', '2142', '', '0.00', '0.00', '416', '  6. Chênh lệch đánh giá lại tài sản', '  5. Difference on revaluation of assets', '412', '', '0.00', '0.00'),
(603, 'DNL', '15', '227', '  3. Tài sản cố định vô hình', '  3. Intangible assets', '213,2143', 'V.10', '0.00', '0.00', '417', '  7. Chênh lệch tỷ giá hối đoái', '  6. Foreign exchange difference', '413', '', '0.00', '0.00'),
(604, 'DNL', '15', '228', '      - Nguyên giá', '     - Historical cost', '213', '', '0.00', '0.00', '418', '  8. Quỹ đầu tư phát triển', '  7. Investment and Development fund', '414', '', '0.00', '0.00'),
(605, 'DNL', '15', '229', '      - Giá trị hao mòn lũy kế (*)', '     - Accumulated depreciation (*)', '2143', '', '0.00', '0.00', '419', '  9. Quỹ hổ trợ sắp xếp doanh nghiệp', '', '417', '', '0.00', '0.00'),
(606, 'DNL', '15', '', '', '', '', '', '0.00', '0.00', '420', '  10. Quỹ khác thuộc vốn chủ sở hữu', ' 9. Other funds', '418', '', '0.00', '0.00'),
(607, 'DNL', '15', '230*', 'III. Bất động sản đầu tư', 'III. Real eatate investment', '231+232', 'V.12', '0.00', '0.00', '421', '  11. Lợi nhuận sau thuế chưa phân phối', ' 10. Undistributed earnings', '421', '', '0.00', '0.00'),
(608, 'DNL', '15', '231', '      - Nguyên giá', '     - Historical cost', '217', '', '0.00', '0.00', '421a', '     - LNST chưa phân phối lũy kế đến cuối kỳ trước', '', '4211', '', '0.00', '0.00'),
(609, 'DNL', '15', '232', '      - Giá trị hao mòn lũy kế (*)', '     - Accumulated depreciation (*)', '2147', '', '0.00', '0.00', '421b', '     - LNST chưa phân phối kỳ này', '', '4212', '', '0.00', '0.00'),
(610, 'DNL', '15', '240*', 'IV. Tài sản dở dang dài hạn', '', '241+242', '', '0.00', '0.00', '422', '  11. Nguồn vốn đầu tư XDCB', ' 11. Resources for capital expenditures', '441', '', '0.00', '0.00'),
(611, 'DNL', '15', '241', '1. Chi phí sản xuất, kinh doanh dở dang dài hạn', '', '1549', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(612, 'DNL', '15', '242', '2. Chi phí xây dựng cơ bản dở dang', '  2. Construction in progress', '241', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(613, 'DNL', '15', '250*', 'V.  Đầu tư tài chính dài hạn', 'IV. Long-term financial investment', '251+252+253+254+255', '', '0.00', '0.00', '430*', 'II. Nguồn kinh phí', 'II. Subsidies and', '431+432', '', '0.00', '0.00'),
(614, 'DNL', '15', '251', '  1. Đầu tư vào công ty con', '  1. Investment in subsidiaries', '221', '', '0.00', '0.00', '431', '  1. Nguồn kinh phí', '  1. Subsidy fund', '461', '', '0.00', '0.00'),
(615, 'DNL', '15', '252', '  2. Đầu tư vào công ty liên doanh ,liên kết', '  2. Investment in associates and interest in Joint Ventures', '222,223', '', '0.00', '0.00', '432', '  2. Nguồn kinh phí đã hình thành TSCĐ', '  2. Funds used to acquire fixed assets', '466', '', '0.00', '0.00'),
(616, 'DNL', '15', '253', '  3. Đầu tư góp vốn vào đơn vị khác', '  3. Other long-term investment', '228', 'V.13', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(617, 'DNL', '15', '254', '  4. Dự phòng đầu tư tài chính dài hạn (*)', '  4. Provision for devaluation of long-term securities investment (*)', '2292', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(618, 'DNL', '15', '255', '  5. Đầu tư nắm giữ đến ngày đáo hạn', '', '12819,12829,12889', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(619, 'DNL', '15', '260*', 'VI. Tài sản dài hạn khác', 'V. Other long-term assets', '261+262+263+268', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(620, 'DNL', '15', '261', '  1. Chi phí trả trước dài hạn', '  1. Long-term prepayment', '2429', 'V.14', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(621, 'DNL', '15', '262', '  2. Tài sản thuế thu nhập hoãn lại', '  2. Deferred income tax assets', '243', 'V.21', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(622, 'DNL', '15', '263', '  3. Thiết bị, vật tư, phụ tùng thay thế dài hạn', '', '15349', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(623, 'DNL', '15', '268', '  4. Tài sản dài hạn khác', '  3. Other long-term assets', '244', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(624, 'DNL', '15', '', '', '', '', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(625, 'DNL', '15', '270***', 'TỔNG CỘNG TÀI SẢN  (270 = 100 + 200)', 'TOTAL ASSETS (270 = 100 + 200)', '100+200', '', '11.00', '0.00', '440***', 'TỔNG CỘNG NGUỒN VỐN (440 = 300 + 400)', 'TOTAL RESOURCE (440 = 300 + 400)', '300+400', '', '0.00', '0.00'),
(626, 'DNL', '16', '100**', 'A - TÀI SẢN', '', '110+120+130+140+150+160+170+180', '', '31.00', '9.00', '300*', 'B - NỢ PHẢI TRẢ', '', '311+312+313+314+315+334+316+317+318+319+320+339+340+341+321+322+343+323+324', '', '0.00', '0.00'),
(627, 'DNL', '16', '110*', 'I. Tiền và các khoản tương đương tiền', '', '111+112', '', '3.00', '0.00', '311', '  1. Phải trả người bán', '', '331', '', '0.00', '0.00'),
(628, 'DNL', '16', '111', '  1.Tiền', '', '111,112', '', '1.00', '0.00', '312', '  2. Người mua trả tiền trước', '', '131', '', '0.00', '0.00'),
(629, 'DNL', '16', '112', '  2. Các khoản tương đương tiền', '', '113', '', '2.00', '0.00', '313', '  3. Thuế và các khoản phải nộp ngân sách nhà nước', '', '133,333', '', '0.00', '0.00'),
(630, 'DNL', '16', '', '', '', '', '', '0.00', '0.00', '314', '  4. Phải trả người lao động', '', '334', '', '0.00', '0.00'),
(631, 'DNL', '16', '120*', 'II. Đầu tư tài chính', '', '121+122+123+124+125', '', '4.00', '0.00', '315', '  5. Chi phí phải trả', '', '335', '', '0.00', '0.00'),
(632, 'DNL', '16', '121', '  1. Chứng khoán kinh doanh', '', '121', '', '2.00', '0.00', '334', '  6. Phải trả nội bộ về vốn kinh doanh', '', '3361', '', '0.00', '0.00'),
(633, 'DNL', '16', '122', '  2. Đầu tư nắm giữ đến ngày đáo hạn', '', '128-1283', '', '2.00', '0.00', '316', '  7. Phải trả nội bộ khác', '', '336-3361', '', '0.00', '0.00'),
(634, 'DNL', '16', '123', '  3. Đầu tư vào công ty con', '', '221', '', '0.00', '0.00', '317', '  8. Phải trả theo tiến độ kế hoạch hợp đồng xây dựng', '', '337', '', '0.00', '0.00'),
(635, 'DNL', '16', '124', '  4. Đầu tư vào công ty liên doanh ,liên kết', '', '222', '', '0.00', '0.00', '318', '  9. Doanh thu chưa thực hiện', '', '3387', '', '0.00', '0.00'),
(636, 'DNL', '16', '125', '  5. Đầu tư góp vốn vào đơn vị khác', '', '228', '', '0.00', '0.00', '319', ' 10. Phải trả khác', '', '1-131-133-171,24,338-3387,344', '', '0.00', '0.00'),
(637, 'DNL', '16', '', '', '', '', '', '0.00', '0.00', '320', ' 11. Vay và nợ thuê tài chính', '', '341', '', '0.00', '0.00'),
(638, 'DNL', '16', '130*', 'III. Các khoản phải thu', '', '131+132+133+134+135+136+137+138', '', '3.00', '0.00', '339', ' 12. Trái phiếu chuyễn đổi', '', '343', '', '0.00', '0.00'),
(639, 'DNL', '16', '131', '  1. Phải thu của khách hàng', '', '131', '', '0.00', '0.00', '340', ' 13. Cổ phiếu ưu đãi', '', '', '', '0.00', '0.00'),
(640, 'DNL', '16', '132', '  2. Trả trước cho người bán', '', '331', '', '3.00', '0.00', '341', ' 14. Thuế thu nhập hoãn lại phải trả', '', '347', '', '0.00', '0.00'),
(641, 'DNL', '16', '133', '  3. Vốn kinh doanh ở đơn vị trực thuộc', '', '1361', '', '0.00', '0.00', '321', ' 15. Dự phòng phải trả', '', '352', '', '0.00', '0.00'),
(642, 'DNL', '16', '134', '  4. Phải thu nội bộ', '', '136-1361', '', '0.00', '0.00', '322', ' 16. Quỹ khen thưởng ,phúc lợi', '', '353', '', '0.00', '0.00'),
(643, 'DNL', '16', '135', '  5. Phải thu về cho vay', '', '1283', '', '0.00', '0.00', '343', ' 17. Quỹ phát triển khoa học và công nghệ', '', '356', '', '0.00', '0.00'),
(644, 'DNL', '16', '136', '  6. Phải thu theo tiến độ kế hoạch HĐ xây dựng', '', '337', '', '0.00', '0.00', '323', ' 18. Quỹ bình ổn giá', '', '357', '', '0.00', '0.00'),
(645, 'DNL', '16', '137', '  7. Phải thu khác', '', '138-1381,14,16,334,335,336,338,34,35', '', '0.00', '0.00', '324', ' 19. Giao dịch mua lại trái phiếu Chính phủ', '', '171', '', '0.00', '0.00'),
(646, 'DNL', '16', '138', '  8. Tài sản thiếu chờ xử lý', '', '1381', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(647, 'DNL', '16', '', '', '', '', '', '0.00', '0.00', '400**', 'C - VỐN CHỦ SỞ HỮU', '', '410+430', '', '0.00', '0.00'),
(648, 'DNL', '16', '140*', 'IV. Hàng tồn kho', '', '15', '', '0.00', '0.00', '410*', 'I. Vốn chủ sở hữu', '', '411+412+413+414+415+418+419+420+421+422', '', '0.00', '0.00'),
(649, 'DNL', '16', '', '', '', '', '', '0.00', '0.00', '411', '  1. Vốn góp chủ sở hữu', '', '4111', '', '0.00', '0.00'),
(650, 'DNL', '16', '150*', ' V.Tài sản cố định', '', '151+152+153', '', '0.00', '0.00', '411a', '       - Cổ phiếu phổ thông có quyền biểu quyết', '', '41111', '', '0.00', '0.00'),
(651, 'DNL', '16', '151', '  1. Tài sản cố định hữu hình', '', '211-2141', '', '0.00', '0.00', '411b', '       - Cổ phiếu ưu đãi', '', '41112', '', '0.00', '0.00'),
(652, 'DNL', '16', '152', '  2. Tài sản cố định thuê tài chính', '', '212-2142', '', '0.00', '0.00', '412', '  2. Thặng dư vốn cổ phần', '', '4112', '', '0.00', '0.00'),
(653, 'DNL', '16', '153', '  3. Tài sản cố định vô hình', '', '213-2143', '', '0.00', '0.00', '413', '  3. Quyền chọn chuyễn đổi trái phiếu', '', '4113', '', '0.00', '0.00'),
(654, 'DNL', '16', '', '', '', '', '', '0.00', '0.00', '414', '  4. Vốn khác của chủ sở hữu', '', '4118', '', '0.00', '0.00'),
(655, 'DNL', '16', '160*', 'VI. Bất động sản đầu tư', '', '217-2147', '', '6.00', '0.00', '415', '  5. Cổ phiếu quỹ (*)', '', '419', '', '0.00', '0.00'),
(656, 'DNL', '16', '', '', '', '', '', '0.00', '0.00', '418', '  6. Quỹ đầu tư phát triển', '', '414', '', '0.00', '0.00'),
(657, 'DNL', '16', '170*', 'VII. Chi phí xây dựng cơ bản dở dang', '', '241', '', '7.00', '0.00', '419', '  7. Quỹ hổ trợ sắp xếp doanh nghiệp', '', '417', '', '0.00', '0.00'),
(658, 'DNL', '16', '', '', '', '', '', '0.00', '0.00', '420', '  8. Quỹ khác thuộc vốn chủ sở hữu', '', '418,412,413', '', '0.00', '0.00'),
(659, 'DNL', '16', '180*', 'VIII. Tài sản khác', '', '181+182+183+184+185+186', '', '8.00', '9.00', '421', '  9. Lợi nhuận sau thuế chưa phân phối', '', '421', '', '0.00', '0.00'),
(660, 'DNL', '16', '181', '  1. Chi phí trả trước', '', '242', '', '0.00', '0.00', '421a', '      - LNST chưa phân phối lũy kế đến cuối kỳ trước', '', '4211', '', '0.00', '0.00'),
(661, 'DNL', '16', '182', '  2. Thuế GTGT được khấu trừ', '', '133', '', '8.00', '0.00', '421b', '      - LNST chưa phân phối kỳ này', '', '4212', '', '0.00', '0.00'),
(662, 'DNL', '16', '183', '  3. Thuế và các khoản khác phải thu Nhà nước', '', '333', '', '0.00', '0.00', '422', ' 10. Nguồn vốn đầu tư XDCB', '', '441', '', '0.00', '0.00'),
(663, 'DNL', '16', '184', '  4. Giao dịch mua bán lại trái phiếu Chính phủ', '', '171', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(664, 'DNL', '16', '185', '  5. Tài sản thuế thu nhập hoãn lại', '', '243', '', '0.00', '9.00', '430*', 'II - Nguồn kinh phí và quỹ khác', '', '431+432', '', '0.00', '0.00'),
(665, 'DNL', '16', '186', '  6. Tài sản khác', '', '242,243,244,229', '', '0.00', '0.00', '431', '   1. Nguồn kinh phí', '', '461', '', '0.00', '0.00'),
(666, 'DNL', '16', '', '', '', '', '', '0.00', '0.00', '432', '   2. Nguồn kinh phí đã hình thành TSCĐ', '', '466', '', '0.00', '0.00'),
(667, 'DNL', '16', '', '', '', '', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(668, 'DNL', '16', '270**', 'TỔNG CỘNG TÀI SẢN  (270 = 100 )', '', '110+120+130+140+150+160+170+180', '', '31.00', '9.00', '440***', 'TỔNG CỘNG NGUỒN VỐN ( 440 = 300 + 400 )', '', '300+400', '', '0.00', '0.00'),
(669, 'DNN', '98', '100*', 'A.TÀI SẢN L/ĐỘNG & ĐẦU TƯ NGẮN HẠN', 'A.CURRENT ASSERTS AND SHORT-TERM IN', '1-129-139-159,3', '', '0.00', '0.00', '300*', 'A.NỢ PHẢI TRẢ', 'A.LIABILITIES', '3,13-139,14', '', '2062267216.00', '2062267216.00'),
(670, 'DNN', '98', '110*', 'I.Tiền', 'I. Capital in cash', '11', '', '0.00', '0.00', '310*', 'I.Nợ ngắn hạn', 'I.Current liabilities', '31,33-3381-335,13-139,14', '', '2062267216.00', '2062267216.00'),
(671, 'DNN', '98', '111', ' 1.Tiền mặt tại quỹ (cả ngân phiếu)', ' 1.Cash in hand (including notes)', '111', '', '0.00', '0.00', '311', ' 1.Vay ngắn hạn', ' 1.Short-term borrowings', '311', '', '570000000.00', '570000000.00'),
(672, 'DNN', '98', '112', ' 2.Tiền gửi ngân hàng', ' 2.Cash in bank', '112', '', '0.00', '0.00', '312', ' 2.Nợ dài hạn đến hạn trả', ' 2.Long-term due liabilities', '315', '', '0.00', '0.00'),
(673, 'DNN', '98', '113', ' 3.Tiền đang chuyển', ' 3.Cash in transit', '113', '', '0.00', '0.00', '313', ' 3.Phải trả cho người bán', ' 3.Payables to seller', '331', '', '554807422.00', '554807422.00'),
(674, 'DNN', '98', '120*', 'II.Các khoản Đầu tư t/chính ng/hạn', 'II.Fiancial short-term investment', '12-129', '', '0.00', '0.00', '314', ' 4.Người mua trả tiền trước', ' 4.Prepaid by buyers', '131', '', '591442331.00', '591442331.00'),
(675, 'DNN', '98', '121', ' 1.Đầu tư chứng khoán ngắn hạn', ' 1.Short-term securities', '121', '', '0.00', '0.00', '315', ' 5.Thuế và các khoản phải nộp NN', ' 5.Tax and obligation to state', '333', '', '198546996.00', '198546996.00'),
(676, 'DNN', '98', '128', ' 2.Đầu tư ngắn hạn khác', ' 2.Other short-term investment', '128', '', '0.00', '0.00', '316', ' 6.Phải trả công nhân viên', ' 6.Payables to employees', '334', '', '22397877.00', '22397877.00'),
(677, 'DNN', '98', '129', ' 3.Dự phòng giãm giá đầu tư ng/hạn', ' 3.Provision for short-term investm', '129', '', '0.00', '0.00', '317', ' 7.Phải trả cho đơn vị nội bộ', ' 7.Internal payables', '336,136', '', '0.00', '0.00'),
(678, 'DNN', '98', '130*', 'III.Các khoản phải thu', 'III.Receivable accounts', '13-1381-139,3', '', '0.00', '0.00', '318', ' 8.Khoản phải trả ,phải nộp khác', ' 8.Others', '338-3381,13-136-139-131,14', '', '10964657.00', '10964657.00'),
(679, 'DNN', '98', '131', ' 1.Phải thu khách hàng', ' 1.Receivable from customers', '131', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(680, 'DNN', '98', '132', ' 2.Trả trước cho người bán', ' 2.Prepaid to seller', '331', '', '0.00', '0.00', '320*', 'II.Nợ dài hạn', 'II.Long-term liabilities', '34-344', '', '0.00', '0.00'),
(681, 'DNN', '98', '133', ' 3.Phải thu nội bộ', ' 3.internal receivables', '136', '', '0.00', '0.00', '321', ' 1.Vay dài hạn', ' 1.Long-term borrowings', '341', '', '0.00', '0.00'),
(682, 'DNN', '98', '134', '   - Vốn KD ở các đơn vị trực thuộc', '   - Working capital in sub-units', '1361', '', '0.00', '0.00', '322', ' 2.Nợ dài hạn', ' 2.Long-term loans', '342', '', '0.00', '0.00'),
(683, 'DNN', '98', '135', '   - Phải thu nội bộ khác', '   - Others', '1362', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(684, 'DNN', '98', '138', ' 4.Các khoản phải thu khác', ' 4.Other receivables', '138-1381,3-331', '', '0.00', '0.00', '330*', 'III.Nợ khác', 'III.Others', '335,3381,344', '', '114107933.00', '114107933.00'),
(685, 'DNN', '98', '139', ' 5.Dự phòng khoản phải thu khó đòi', ' 5.Provision for bad loans', '139', '', '0.00', '0.00', '331', ' 1.Chi phí phải trả', ' 1.Payable cost', '335', '', '114107933.00', '114107933.00'),
(686, 'DNN', '98', '140*', 'IV.Hàng tồn kho', 'IV.Inventories', '15-159', '', '0.00', '0.00', '332', ' 2.Tài sản thừa chờ xử lý', ' 2.Surplus under pendency', '3381', '', '0.00', '0.00'),
(687, 'DNN', '98', '141', ' 1.Hàng mua đang đi trên đường', ' 1.Goods in transfer', '151', '', '0.00', '0.00', '333', ' 3.Nhận ký quỹ ,ký cược dài hạn', ' 3.Receipts of long-term deposits', '344', '', '0.00', '0.00'),
(688, 'DNN', '98', '142', ' 2.Nguyên liệu,vật liệu tồn kho', ' 2.Raw materials', '152', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(689, 'DNN', '98', '143', ' 3.Công cụ ,dung cụ trong kho', ' 3.Tools and intruments', '153', '', '0.00', '0.00', '400*', 'B.NGUỒN VỐN CHỦ SỞ HỮU', 'B.OWNER`S EQUITY', '4,412,413,421,431', '', '993655624.00', '993655624.00'),
(690, 'DNN', '98', '144', ' 4.Chi phí sản xuất KD dở dang', ' 4.Work in process', '154', '', '0.00', '0.00', '410*', 'I.Vốn - quỹ', 'I.Capital sourses and funds', '41,42,43,44,412,413,421,431', '', '993655624.00', '993655624.00'),
(691, 'DNN', '98', '145', ' 5.Thành phẩm tồn kho', ' 5.Finished products', '155', '', '0.00', '0.00', '411', ' 1.Vốn kinh doanh', ' 1.Business capital', '411', '', '849468096.00', '849468096.00'),
(692, 'DNN', '98', '146', ' 6.Hàng hoá tồn kho', ' 6.Goods in stock', '156', '', '0.00', '0.00', '412', ' 2.Chênh lệch đánh giá lại tài sản', ' 2.Differences of revaluation', '412', '', '0.00', '0.00'),
(693, 'DNN', '98', '147', ' 7.Hàng gửi đi bán', ' 7.Consigned goods for sale', '157', '', '0.00', '0.00', '413', ' 3.Chênh lệch tỷ giá', ' 3.Differences of exchange rate', '413', '', '0.00', '0.00'),
(694, 'DNN', '98', '149', ' 8.Dự phòng giãm giá hàng tồn', ' 8.Provision for inventories', '159', '', '0.00', '0.00', '414', ' 4.Quỹ đầu tư phát triển', ' 4.Business development funds', '414', '', '24170780.00', '24170780.00'),
(695, 'DNN', '98', '150*', 'V.Tài sản lưu động khác', 'V.Other current assets', '14,1381', '', '0.00', '0.00', '415', ' 5.Quỹ dự phòng tài chính', ' 5.Reserved funds', '415', '', '0.00', '0.00'),
(696, 'DNN', '98', '151', ' 1.Tạm ứng', ' 1.Advances', '141', '', '0.00', '0.00', '416', ' 6.Quỹ dự phòng trợ cấp mất việc', ' 6.Reserved funds', '416', '', '-10688000.00', '-10688000.00'),
(697, 'DNN', '98', '152', ' 2.Chi phí trả trước', ' 2.Prepaid costs', '1421', '', '0.00', '0.00', '417', ' 7.Lãi chưa phân phối', ' 7.Undestributed profit', '421', '', '92853580.00', '92853580.00'),
(698, 'DNN', '98', '153', ' 3.Chi phí chờ kết chuyển', ' 3.Pending costs for transfer', '1422', '', '0.00', '0.00', '418', ' 8.Quỹ khen thưởng phúc lợi', ' 8.Reward and benifit funds', '431', '', '37851168.00', '37851168.00'),
(699, 'DNN', '98', '154', ' 4.Tài sản thiếu chờ xử lý', ' 4.Loss under pendency', '1381', '', '0.00', '0.00', '', ' 9.Nguồn vốn đầu tư xây dựng cơ bản', ' 9.Capital investment sourses', '441', '', '0.00', '0.00'),
(700, 'DNN', '98', '155', ' 5.Khoản thế chấp,ký cược,ký quỹ NH', ' 5.Short-term mortgage and deposit', '144', '', '0.00', '0.00', '420*', 'II.Nguồn kinh phí', 'II.Budget resources', '45,46', '', '0.00', '0.00'),
(701, 'DNN', '98', '160*', 'VI.Chi sự nghiệp', 'VI.Administratvie', '161', '', '0.00', '0.00', '421', ' 1.Quỹ quản lý của cấp trên', ' 1.Management funds of higher level', '451', '', '0.00', '0.00'),
(702, 'DNN', '98', '161', ' 1.Chi sự nghiệp năm trước', ' 1.For previous year', '1611', '', '0.00', '0.00', '422', ' 2.Nguồn kinh phí sự nghiệp', ' 2.Administrative funds', '461', '', '0.00', '0.00'),
(703, 'DNN', '98', '162', ' 2.Chi sự nghiệp năm nay', ' 2.For current year', '1612', '', '0.00', '0.00', '423', '   - Nguồn kinh phí năm trước', '  - Of previous year', '4611', '', '0.00', '0.00'),
(704, 'DNN', '98', '200*', 'B.TÀI SẢN CỐ ĐỊNH & ĐẦU TƯ DÀI HẠN', 'B.FIXED ASSETS AND LONGTERM INVERST', '2-214-229', '', '0.00', '0.00', '424', '   - Nguồn kinh phí năm nay', '  - Of current year', '4612', '', '0.00', '0.00'),
(705, 'DNN', '98', '210*', 'I.Tài sản cố định', 'I.Fixed assets', '21-214', '', '0.00', '0.00', '425', ' 3.Nguồn kinh phí đã h/thành TSCĐ', ' 3.Administrative funds', '466', '', '0.00', '0.00'),
(706, 'DNN', '98', '211', ' 1.Tài sản cố định hữu hình', ' 1.Tangible fixed assets', '211,2141', '', '0.00', '0.00', '', '', '', '', '', '3055922840.00', '3055922840.00'),
(707, 'DNN', '98', '212', '   - Nguyên giá', '  - Original rate', '211', '', '0.00', '0.00', '430*', '       TỔNG CỘNG NGUỒN VỐN', '         TOTAL RESOURCES', '3,13-139,4,412,413,421,431,14', '', '0.00', '0.00'),
(708, 'DNN', '98', '213', '   - Giá trị hao mòn luỹ kế', '  - Accumulated depreciation', '2141', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(709, 'DNN', '98', '214', ' 2.Tài sản cố định thuê tài chính', ' 2.Leased financial assets', '212,2142', '', '0.00', '0.00', '   *', '                  CÁC CHỈ TIÊU', '', '', '', '0.00', '0.00'),
(710, 'DNN', '98', '215', '   - Nguyên giá', '  - Original rate', '212', '', '0.00', '0.00', '   *', '    NGOÀI BẢNG CÂN ĐỐI KÊ TOÁN', '----------  INDICATORS ------------', '', '', '0.00', '0.00'),
(711, 'DNN', '98', '216', '   - Giá trị hao mòn luỹ kế', '  - Accumulated depreciation', '2142', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(712, 'DNN', '98', '217', ' 3.Tài sản cố định vô hình', ' 1.Intangible fixed assets', '213,2143', '', '0.00', '0.00', '', ' 1.Tài sản thuê ngoài', '1.Leased assets from outside', '001', '', '0.00', '0.00'),
(713, 'DNN', '98', '218', '   - Nguyên giá', '  - Original rate', '213', '', '0.00', '0.00', '', ' 2.Vật tư hàng hoá giữ hộ,gia công', '2.Materials and goods entrusted for', '002', '', '0.00', '0.00'),
(714, 'DNN', '98', '219', '   - Giá trị hao mòn luỹ kế', '  - Accumulated depreciation', '2143', '', '0.00', '0.00', '', ' 3.Hàng hoá nhận bán hộ ,ký gửi', '3.Goods to be consigned and depsite', '003', '', '0.00', '0.00'),
(715, 'DNN', '98', '220*', 'II.Các khoản đầu tư t/chính dài hạn', 'II.Long-term Financial investment', '22-229', '', '0.00', '0.00', '', ' 4.Nợ khó đòi đã xử lý', '4.Settled bad loans', '004', '', '0.00', '0.00'),
(716, 'DNN', '98', '221', ' 1.Đầu tư chứng khoán dài hạn', ' 1.Long-term securities', '221', '', '0.00', '0.00', '', ' 5.Ngoại tệ các loại', '5.Foreign currencies', '007', '', '0.00', '0.00'),
(717, 'DNN', '98', '222', ' 2.Góp vốn liên doanh', ' 2.Join-venture contribution', '222', '', '0.00', '0.00', '', '   -Tiền mặt Việt Nam', '  - ...', '0071', '', '0.00', '0.00'),
(718, 'DNN', '98', '228', ' 3.Các khoản đầu tư dài hạn khác', ' 3.Others', '228', '', '0.00', '0.00', '', '   -...', '  - ...', '0072', '', '0.00', '0.00'),
(719, 'DNN', '98', '229', ' 4.Dự phòng giãm giá đầu tư dài hạn', ' 4.Provision for devaluation', '229', '', '0.00', '0.00', '', '   -...', '  - ...', '0073', '', '0.00', '0.00'),
(720, 'DNN', '98', '230*', 'III.Chi phí xây dựng cơ bản dở dang', 'III.Cost for contruction in process', '241', '', '0.00', '0.00', '', ' 6.Hạn mức kinh phí còn lại', '6.Available depreciation amount', '008', '', '0.00', '0.00'),
(721, 'DNN', '98', '240*', 'IV.Các khoản ký quỹ,ký cược dài hạn', 'IV.Long-term deposits', '244', '', '0.00', '0.00', '', ' 7.Nguồn vốn kh/hao cơ bản hiện có', '', '009', '', '0.00', '0.00'),
(722, 'DNN', '98', '250*', '         TỔNG CỘNG TÀI SẢN', '            TOTAL ASSETS', '1-129-139-159,2-214-229,3', '', '0.00', '0.00', '   *', '     CÔNG TAI SAN NGOAI BANG', '         TOTAL INDICATORS', '00', '', '0.00', '0.00'),
(723, 'DNN', '99', '100*', 'A.TÀI SẢN LĐ & ĐẦU TƯ NGẮN HẠN', 'A.CURRENT ASSERTS AND SHORT-TERM IN', '1-16-129-139-159,3', '', '0.00', '0.00', '300*', 'A.NỢ PHẢI TRẢ', 'A.LIABILITIES', '3,13-139,14', '', '2062267216.00', '2062267216.00'),
(724, 'DNN', '99', '110*', 'I.Tiền', 'I. Capital in cash', '11', '', '0.00', '0.00', '310*', 'I.Nợ ngắn hạn', 'I.Current liabilities', '31,33-3381-335,13-139,14', '', '2062267216.00', '2062267216.00'),
(725, 'DNN', '99', '111', ' 1.Tiền mặt tại quỹ (gồm cả ngân phiếu)', ' 1.Cash in hand (including notes)', '111', '', '0.00', '0.00', '311', ' 1.Vay ngắn hạn', ' 1.Short-term borrowings', '311', '', '570000000.00', '570000000.00'),
(726, 'DNN', '99', '112', ' 2.Tiền gửi ngân hàng', ' 2.Cash in bank', '112', '', '0.00', '0.00', '312', ' 2.Nợ dài hạn đến hạn trả', ' 2.Long-term due liabilities', '315', '', '0.00', '0.00'),
(727, 'DNN', '99', '113', ' 3.Tiền đang chuyển', ' 3.Cash in transit', '113', '', '0.00', '0.00', '313', ' 3.Phải trả cho người bán', ' 3.Payables to seller', '331', '', '554807422.00', '554807422.00'),
(728, 'DNN', '99', '120*', 'II.Các khoản Đầu tư t/chính ng/hạn', 'II.Fiancial short-term investment', '12-129', '', '0.00', '0.00', '314', ' 4.Người mua trả tiền trước', ' 4.Prepaid by buyers', '131', '', '591442331.00', '591442331.00'),
(729, 'DNN', '99', '121', ' 1.Đầu tư chứng khoán ngắn hạn', ' 1.Short-term securities', '121', '', '0.00', '0.00', '315', ' 5.Thuế và các khoản phải nộp NN', ' 5.Tax and obligation to state', '333', '', '198546996.00', '198546996.00'),
(730, 'DNN', '99', '128', ' 2.Đầu tư ngắn hạn khác', ' 2.Other short-term investment', '128', '', '0.00', '0.00', '316', ' 6.Phải trả công nhân viên', ' 6.Payables to employees', '334', '', '22397877.00', '22397877.00'),
(731, 'DNN', '99', '129', ' 3.Dự phòng giãm giá đầu tư ng/hạn (*)', ' 3.Provision for short-term investm', '129', '', '0.00', '0.00', '317', ' 7.Phải trả cho đơn vị nội bộ', ' 7.Internal payables', '336,136', '', '0.00', '0.00'),
(732, 'DNN', '99', '130*', 'III.Các khoản phải thu', 'III.Receivable accounts', '13-1381-139,3', '', '0.00', '0.00', '318', ' 8.Khoản phải trả ,phải nộp khác', ' 8.Others', '338-3381,13-139-131-136,14', '', '10964657.00', '10964657.00'),
(733, 'DNN', '99', '131', ' 1.Phải thu khách hàng', ' 1.Receivable from customers', '131', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(734, 'DNN', '99', '132', ' 2.Trả trước cho người bán', ' 2.Prepaid to seller', '331', '', '0.00', '0.00', '320*', 'II.Nợ dài hạn', 'II.Long-term liabilities', '34-344', '', '0.00', '0.00'),
(735, 'DNN', '99', '133', ' 3.Thuế giá trị gia tăng được khấu trừ', ' 3.VAT discountable', '133', '', '0.00', '0.00', '321', ' 1.Vay dài hạn', ' 1.Long-term borrowings', '341', '', '0.00', '0.00'),
(736, 'DNN', '99', '134', ' 4.Phải thu nội bộ', ' 4.internal receivables', '136', '', '0.00', '0.00', '322', ' 2.Nợ dài hạn', ' 2.Long-term loans', '342', '', '0.00', '0.00'),
(737, 'DNN', '99', '135', '   - Vốn KD ở các đơn vị trực thuộc', '   - Working capital in sub-units', '1361', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(738, 'DNN', '99', '136', '   - Phải thu nội bộ khác', '   - Others', '1362', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(739, 'DNN', '99', '138', ' 5.Các khoản phải thu khác', ' 5.Other receivables', '138-1381,3-331', '', '0.00', '0.00', '330*', 'III.Nợ khác', 'III.Others', '335,3381,344', '', '114107933.00', '114107933.00'),
(740, 'DNN', '99', '139', ' 6.Dự phòng khoản phải thu khó đòi  (*)', ' 5.Provision for bad loans', '139', '', '0.00', '0.00', '331', ' 1.Chi phí phải trả', ' 1.Payable cost', '335', '', '114107933.00', '114107933.00'),
(741, 'DNN', '99', '140*', 'IV.Hàng tồn kho', 'IV.Inventories', '15-159', '', '0.00', '0.00', '332', ' 2.Tài sản thừa chờ xử lý', ' 2.Surplus under pendency', '3381', '', '0.00', '0.00'),
(742, 'DNN', '99', '141', ' 1.Hàng mua đang đi trên đường', ' 1.Goods in transfer', '151', '', '0.00', '0.00', '333', ' 3.Nhận ký quỹ ,ký cược dài hạn', ' 3.Receipts of long-term deposits', '344', '', '0.00', '0.00'),
(743, 'DNN', '99', '142', ' 2.Nguyên liệu,vật liệu tồn kho', ' 2.Raw materials', '152', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(744, 'DNN', '99', '143', ' 3.Công cụ ,dung cụ trong kho', ' 3.Tools and intruments', '153', '', '0.00', '0.00', '400*', 'B.NGUỒN VỐN CHỦ SỞ HỮU', 'B.OWNER`S EQUITY', '4,412,413,421,431', '', '993655624.00', '993655624.00'),
(745, 'DNN', '99', '144', ' 4.Chi phí sản xuất KD dở dang', ' 4.Work in process', '154', '', '0.00', '0.00', '410*', 'I.Vốn - quỹ', 'I.Capital sourses and funds', '41-416,42,44,412,413,421', '', '993655624.00', '993655624.00'),
(746, 'DNN', '99', '145', ' 5.Thành phẩm tồn kho', ' 5.Finished products', '155', '', '0.00', '0.00', '411', ' 1.Vốn kinh doanh', ' 1.Business capital', '411', '', '849468096.00', '849468096.00'),
(747, 'DNN', '99', '146', ' 6.Hàng hoá tồn kho', ' 6.Goods in stock', '156', '', '0.00', '0.00', '412', ' 2.Chênh lệch đánh giá lại tài sản', ' 2.Differences of revaluation', '412', '', '0.00', '0.00'),
(748, 'DNN', '99', '147', ' 7.Hàng gửi đi bán', ' 7.Consigned goods for sale', '157', '', '0.00', '0.00', '413', ' 3.Chênh lệch tỷ giá', ' 3.Differences of exchange rate', '413', '', '0.00', '0.00'),
(749, 'DNN', '99', '149', ' 8.Dự phòng giãm giá hàng tồn kho (*)', ' 8.Provision for inventories', '159', '', '0.00', '0.00', '414', ' 4.Quỹ đầu tư phát triển', ' 4.Business development funds', '414', '', '24170780.00', '24170780.00'),
(750, 'DNN', '99', '150*', 'V.Tài sản lưu động khác', 'V.Other current assets', '14,1381', '', '0.00', '0.00', '415', ' 5.Quỹ dự phòng tài chính', ' 5.Reserved funds', '415,417,419', '', '0.00', '0.00'),
(751, 'DNN', '99', '151', ' 1.Tạm ứng', ' 1.Advances', '141', '', '0.00', '0.00', '416', ' 6.Lợi nhuận chưa phân phối', ' 6.Undestributed profit', '421', '', '-10688000.00', '-10688000.00'),
(752, 'DNN', '99', '152', ' 2.Chi phí trả trước', ' 2.Prepaid costs', '1421', '', '0.00', '0.00', '417', ' 7.Nguồn vốn đầu tư xây dựng cơ bản', ' 7.Capital investment sourses', '441', '', '92853580.00', '92853580.00'),
(753, 'DNN', '99', '153', ' 3.Chi phí chờ kết chuyển', ' 3.Pending costs for transfer', '1422', '', '0.00', '0.00', '420*', 'II.Nguồn kinh phí ,quỹ khác', 'II.Budget resources ,other funds', '45,46,416,431', '', '37851168.00', '37851168.00'),
(754, 'DNN', '99', '154', ' 4.Tài sản thiếu chờ xử lý', ' 4.Loss under pendency', '1381', '', '0.00', '0.00', '421', ' 1.Quỹ dự phòng trợ cấp mất việc', ' 1.Reserved funds', '416', '', '0.00', '0.00'),
(755, 'DNN', '99', '155', ' 5.Các khoản cầm cố,ký cược,ký quỹ NH', ' 5.Short-term mortgage and deposit', '144', '', '0.00', '0.00', '422', ' 2.Quỹ khen thưởng phúc lợi', ' 2.Reward and benifit funds', '431', '', '0.00', '0.00'),
(756, 'DNN', '99', '160*', 'VI.Chi sự nghiệp', 'VI.Administratvie', '161', '', '0.00', '0.00', '423', ' 3.Quỹ quản lý của cấp trên', ' 3.Management funds of higher level', '451', '', '0.00', '0.00'),
(757, 'DNN', '99', '161', ' 1.Chi sự nghiệp năm trước', ' 1.For previous year', '1611', '', '0.00', '0.00', '424', ' 4.Nguồn kinh phí sự nghiệp', ' 4.Administrative funds', '461', '', '0.00', '0.00'),
(758, 'DNN', '99', '162', ' 2.Chi sự nghiệp năm nay', ' 2.For current year', '1612', '', '0.00', '0.00', '425', '   - Nguồn kinh phí năm trước', '  - Of previous year', '4611', '', '0.00', '0.00'),
(759, 'DNN', '99', '200*', 'B.TÀI SẢN CỐ ĐỊNH & ĐẦU TƯ DÀI HẠN', 'B.FIXED ASSETS AND LONGTERM INVERST', '2-214-229', '', '0.00', '0.00', '426', '   - Nguồn kinh phí năm nay', '  - Of current year', '4612', '', '0.00', '0.00'),
(760, 'DNN', '99', '210*', 'I.Tài sản cố định', 'I.Fixed assets', '21-214', '', '0.00', '0.00', '427', ' 5.Nguồn kinh phí đã h/thành TSCĐ', ' 5.Administrative funds', '466', '', '0.00', '0.00'),
(761, 'DNN', '99', '211', ' 1.Tài sản cố định hữu hình', ' 1.Tangible fixed assets', '211,2141', '', '0.00', '0.00', '', '', '', '', '', '3055922840.00', '3055922840.00'),
(762, 'DNN', '99', '212', '   - Nguyên giá', '  - Original rate', '211', '', '0.00', '0.00', '430*', '       TỔNG CỘNG NGUỒN VỐN', '         TOTAL RESOURCES', '3,13-139,4,412,413,421,431,14', '', '0.00', '0.00'),
(763, 'DNN', '99', '213', '   - Giá trị hao mòn luỹ kế (*)', '  - Accumulated depreciation', '2141', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(764, 'DNN', '99', '214', ' 2.Tài sản cố định thuê tài chính', ' 2.Leased financial assets', '212,2142', '', '0.00', '0.00', '', '                  CÁC CHỈ TIÊU', '               ITEMS', '', '', '0.00', '0.00'),
(765, 'DNN', '99', '215', '   - Nguyên giá', '  - Original rate', '212', '', '0.00', '0.00', '', '    NGOÀI BẢNG CÂN ĐỐI KÊ TOÁN', '----------  INDICATORS ------------', '', '', '0.00', '0.00'),
(766, 'DNN', '99', '216', '   - Giá trị hao mòn luỹ kế (*)', '  - Accumulated depreciation', '2142', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(767, 'DNN', '99', '217', ' 3.Tài sản cố định vô hình', ' 1.Intangible fixed assets', '213,2143', '', '0.00', '0.00', '', ' 1.Tài sản thuê ngoài', '1.Leased assets from outside', '001', '', '0.00', '0.00'),
(768, 'DNN', '99', '218', '   - Nguyên giá', '  - Original rate', '213', '', '0.00', '0.00', '', ' 2.Vật tư hàng hoá giữ hộ,gia công', '2.Materials and goods entrusted for', '002', '', '0.00', '0.00'),
(769, 'DNN', '99', '219', '   - Giá trị hao mòn luỹ kế (*)', '  - Accumulated depreciation', '2143', '', '0.00', '0.00', '', ' 3.Hàng hoá nhận bán hộ ,ký gửi', '3.Goods to be consigned and depsite', '003', '', '0.00', '0.00'),
(770, 'DNN', '99', '220*', 'II.Các khoản đầu tư t/chính dài hạn', 'II.Long-term Financial investment', '22-229', '', '0.00', '0.00', '', ' 4.Nợ khó đòi đã xử lý', '4.Settled bad loans', '004', '', '0.00', '0.00'),
(771, 'DNN', '99', '221', ' 1.Đầu tư chứng khoán dài hạn', ' 1.Long-term securities', '221', '', '0.00', '0.00', '', ' 5.Ngoại tệ các loại', '5.Foreign currencies', '007', '', '0.00', '0.00'),
(772, 'DNN', '99', '222', ' 2.Góp vốn liên doanh', ' 2.Join-venture contribution', '222', '', '0.00', '0.00', '', '   -Tiền mặt Việt Nam', '  - vnd', '0071', '', '0.00', '0.00'),
(773, 'DNN', '99', '228', ' 3.Đầu tư dài hạn khác', ' 3.Others', '228', '', '0.00', '0.00', '', '   -...', '  - ...', '0072', '', '0.00', '0.00'),
(774, 'DNN', '99', '229', ' 4.Dự phòng giãm giá đầu tư dài hạn (*)', ' 4.Provision for devaluation', '229', '', '0.00', '0.00', '', '   -...', '  - ...', '0073', '', '0.00', '0.00'),
(775, 'DNN', '99', '230*', 'III.Chi phí xây dựng cơ bản dở dang', 'III.Cost for contruction in process', '241', '', '0.00', '0.00', '', ' 6.Hạn mức kinh phí còn lại', '6.Available depreciation amount', '008', '', '0.00', '0.00'),
(776, 'DNN', '99', '240*', 'IV.Các khoản ký quỹ,ký cược dài hạn', 'IV.Long-term deposits', '244', '', '0.00', '0.00', '', ' 7.Nguồn vốn kh/hao cơ bản hiện có', '7.Accumulated depreciation', '009', '', '0.00', '0.00'),
(777, 'DNN', '99', '241*', ' V.Chi phí trả trước dài hạn', ' V.Long-term Prepaid costs', '242', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(778, 'DNN', '99', '250*', '         TỔNG CỘNG TÀI SẢN', '            TOTAL ASSETS', '1-16-129-139-159,2-214-229,3', '', '0.00', '0.00', '', '     CỘNG TÀI SẢN NGOÀI BẢNG', '         TOTAL INDICATORS', '00', '', '0.00', '0.00'),
(779, 'DNN', '05', '100*', 'A - TÀI SẢN NGẮN HẠN (100) = 110+120+130+140+150', 'A - CURRENT ASSETS (100) = 110+120+130+140+150', '1-16-129-159-15929-1319-139-1399-13619-13689-13889,33-335-3369-33889-3319', '', '0.00', '0.00', '300*', 'A - NỢ PHẢI TRẢ  (300 = 310 + 320)', 'A - LIABILITIES (300 = 310 + 320)', '3,13-139,14', '', '0.00', '0.00'),
(780, 'DNN', '05', '110*', 'I. Tiền và các khoản tương đương tiền', 'I. Cash and equivalentce', '11,12119,12129,12819,12889', 'III.0', '0.00', '0.00', '310*', 'I. Nợ ngắn hạn', 'I. Current liabilities', '31,33-3319-3369-3359-33889,352-3529,13-139-13619-13689-1319-13889,14', '', '0.00', '0.00'),
(781, 'DNN', '05', '120*', 'II. Các khoản đầu tư tài chính ngắn hạn', 'II. Short-term financial investments', '12-129-12119-12129-12819-12889,159-1591', 'III.0', '0.00', '0.00', '311', '  1. Vay và nợ ngắn hạn', '  1. Short-term loan and borrowing', '311,315', '', '0.00', '0.00'),
(782, 'DNN', '05', '121', '  1. Đầu tư ngắn hạn', '  1. Short-term securities investments', '121-12119-12129,128-12819-12889', '', '0.00', '0.00', '312', '  2. Phải trả người bán', '  2. Trade payables', '331-3319', '', '0.00', '0.00'),
(783, 'DNN', '05', '129', '  2. Dự phòng giảm giá chứng khoán đầu tư ngắn hạn (*)', '  2. Provision for devaluation of short-term securities investment (*)', '1591,129', '', '0.00', '0.00', '313', '  3. Người mua trả tiền trước', '  3. Advance from customers', '131-1319', '', '0.00', '0.00'),
(784, 'DNN', '05', '', '', '', '', '', '0.00', '0.00', '314', '  4. Thuế và các khoản phải nộp Nhà nước', '  4. Taxes and payables to State Budget', '133,333', 'III.0', '0.00', '0.00'),
(785, 'DNN', '05', '130*', 'III. Các khoản phải thu', 'III. Account receivable', '13-133-139-1319-13619-13689-13889,1592-15929,33-333-335-3369-33889-3319', '', '0.00', '0.00', '315', '  5. Phải trả người lao động', '  5. Payables to employees', '334', '', '0.00', '0.00'),
(786, 'DNN', '05', '131', '  1. Phải thu khách hàng', '  1. Trade receivable', '131-1319', '', '0.00', '0.00', '316', '  6. Chi phí phải trả', '  6. Accrued expenses', '335-3359', '', '0.00', '0.00'),
(787, 'DNN', '05', '132', '  2. Trả trước cho người bán', '  2. Advances to suppliers', '331-3319', '', '0.00', '0.00', '318', '  7. Các khoản phải trả, phải nộp khác', '  7. Other payables', '338-33889,14,138-13889,337,336-3369,136-13619-13689', '', '0.00', '0.00'),
(788, 'DNN', '05', '138', '  3. Các khoản phải thu khác', '  3. Other receivables', '136-13619-13689,336-3369,138-13889,338-33889,334,337', '', '0.00', '0.00', '319', '  8. Dự phòng phải trả ngắn hạn', '  8. Provision for short-term payables', '352-3529', '', '0.00', '0.00'),
(789, 'DNN', '05', '139', '  4. Dự phòng các khoản phải thu khó đòi (*)', '  4. Provision for doubtful debts (*)', '1592-15929,139', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(790, 'DNN', '05', '', '', '', '', '', '0.00', '0.00', '320*', 'II. Nợ dài hạn', 'II. Long-term liabilities', '3319,3369,13619,13689,1319,13889,3359,33889,34,351,3529', '', '0.00', '0.00'),
(791, 'DNN', '05', '140*', 'IV. Hàng tồn kho', 'IV. Inventories', '15-1593', '', '0.00', '0.00', '321', '  1. Vay và nợ dài hạn', '  1. Long-term loan and brrowings', '341,342,343', '', '0.00', '0.00'),
(792, 'DNN', '05', '141', '  1. Hàng tồn kho', '  1. Inventories', '151,152,153,154,155,156,157,158', 'III.0', '0.00', '0.00', '322', '  2. Quỹ dự phòng trợ cấp mất việc làm', '  2. Provision for unemployment allowance', '351', '', '0.00', '0.00'),
(793, 'DNN', '05', '149', '  2. Dự phòng giảm giá hàng tồn kho (*)', '  2. Provision for inventories (*)', '1593,159', '', '0.00', '0.00', '328', '  3. Phải trả  ,phải nộp dài hạn khác', '  3. Long-term loan and brrowings', '1319,13889,3359,33889,344,3319,3369,13619,13689', '', '0.00', '0.00'),
(794, 'DNN', '05', '', '', '', '', '', '0.00', '0.00', '329', '  4. Dự phòng phải trả dài hạn', '  4. Provision for long-term payables', '3529', '', '0.00', '0.00'),
(795, 'DNN', '05', '150*', 'V. Tài sản ngắn hạn khác', 'V. Other current assets', '142,133,333,141,144', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(796, 'DNN', '05', '151', '  1. Thuế GTGT được khấu trừ', '  1. VAT deductibles', '133', '', '0.00', '0.00', '400*', 'B - VỐN CHỦ SỞ HỮU (400 = 410 + 430)', 'B - OWNER`S EQUITY (400 = 410 + 430)', '4,412,413,421,431,419,461', '', '0.00', '0.00'),
(797, 'DNN', '05', '152', '  2. Thuế và các khoản khác phải thu Nhà nước', '  2. Tax and receivables from budget', '333', '', '0.00', '0.00', '410*', 'I. Vốn chủ sở hữu', 'I. Equity', '41,42,44,412,413,421,419', 'III.0', '0.00', '0.00'),
(798, 'DNN', '05', '158', '  3. Tài sản ngắn hạn khác', '  3. Other current assets', '141,142,144', '', '0.00', '0.00', '411', '  1. Vốn đầu tư của chủ sở hữu', '  1. Paid-in capital', '4111', '', '0.00', '0.00'),
(799, 'DNN', '05', '', '', '', '', '', '0.00', '0.00', '412', '  2. Thặng dư vốn cổ phần', '  2. Paid-in capital in excess of par value', '4112', '', '0.00', '0.00'),
(800, 'DNN', '05', '200*', 'B - TÀI SẢN DÀI HẠN', 'B - NON-CURRENT ASSETS', '1319,3319,13619,13689,3369,13889,33889,2-214-229,15929', '', '0.00', '0.00', '413', '  3. Vốn khác của chủ sở hữu', '  3. Other padi-in capital', '4118', '', '0.00', '0.00'),
(801, 'DNN', '05', '', '  (200 = 210 + 220 + 230 + 240 )', '  (200 = 210 + 220 + 230 + 240 )', '', '', '0.00', '0.00', '414', '  4. Cổ phiếu ngân quỹ (*)', '  4. Treasury stocks (*)', '419', '', '0.00', '0.00'),
(802, 'DNN', '05', '', '', '', '', '', '0.00', '0.00', '415', '  5. Chênh lệch tỷ giá hối đoái', '  5. Foreign exchange difference', '412,413', '', '0.00', '0.00'),
(803, 'DNN', '05', '210*', 'I. Tài sản cố định', 'I. Fixed assets', '21-217,241,214-2147', 'III.0', '0.00', '0.00', '416', '  6. Quỹ khác thuộc vốn chủ sở hữu', '  6. Other funds', '418,414,415,441', '', '0.00', '0.00'),
(804, 'DNN', '05', '211', '  1 - Nguyên giá', '   1. Historical cost', '211,212,213', '', '0.00', '0.00', '417', '  7. Lợi nhuận sau thuế chưa phân phối', '  7. Undistributed earnings', '421', '', '0.00', '0.00'),
(805, 'DNN', '05', '212', '  2 - Giá trị hao mòn lũy kế (*)', '   2. Accumulated depreciation (*)', '214-2147', '', '0.00', '0.00', '430*', 'II.Quỹ khen thưởng, phúc lợi', '', '431', '', '0.00', '0.00'),
(806, 'DNN', '05', '213', '  3. Chi phí xây dựng cơ bản dở dang', '   3. Construction in progress', '241', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(807, 'DNN', '05', '', '', '', '', '', '0.00', '0.00', '440*', 'TỔNG CỘNG NGUỒN VỐN (440 = 300 + 400)', 'TOTAL RESOURCE (440 = 300 + 400)', '3,13-139,14,4,412,413,421,431,419,461', '', '0.00', '0.00'),
(808, 'DNN', '05', '220*', 'II. Bất động sản đầu tư', 'III. Real eatate investment', '217,2147', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(809, 'DNN', '05', '221', '      - Nguyên giá', '   1. Historical cost', '217', '', '0.00', '0.00', '', '                 CÁC CHỈ TIÊU', '', '', '', '0.00', '0.00'),
(810, 'DNN', '05', '222', '      - Giá trị hao mòn lũy kế (*)', '   2. Accumulated depreciation (*)', '2147', '', '0.00', '0.00', '', '   NGOÀI BẢNG CÂN ĐỐI KÊ TOÁN', '                OFF BALANCE SHEET ITEMS', '', '', '0.00', '0.00'),
(811, 'DNN', '05', '230*', 'III. Các khoản đầu tư tài chính dài hạn', 'IV. Long-term financial investment', '22-229', 'III.0', '0.00', '0.00', '', '  1. Tài sản thuê ngoài', '  1. Operating lease assets', '001', '', '0.00', '0.00'),
(812, 'DNN', '05', '231', '  1. Đầu tư tài chính dài hạn', '  1. Investment in associates and interest in Joint Ventures', '221,222,223,228', '', '0.00', '0.00', '', '  2. Vật tư, hàng hóa nhận giữ hộ, nhận gia công', '  2. Goods held under trust or for processing', '002', '', '0.00', '0.00'),
(813, 'DNN', '05', '239', '  2. Dự phòng giảm giá đầu tư tài chính dài hạn (*)', '  2. Provision for devaluation of long-term securities investment (*)', '229', '', '0.00', '0.00', '', '  3. Hàng hóa nhận bán hộ, nhận ký gửi ,ký cược', '  3. Goods received', '003', '', '0.00', '0.00'),
(814, 'DNN', '05', '', '', '', '', '', '0.00', '0.00', '', '  4. Nợ khó đòi đã xử lý', '  4. Bad debts written off', '004', '', '0.00', '0.00'),
(815, 'DNN', '05', '240*', 'IV. Tài sản dài hạn khác', 'V. Other long-term assets', '1319,3319,13619,13689,3369,13889,33889,244,242,15929', '', '0.00', '0.00', '', '  5. Ngoại tệ các loại', '  5. Foreign currencies', '007', '', '0.00', '0.00'),
(816, 'DNN', '05', '241', '  1. Phải thu dài hạn khác', '  1. Long-term prepayment', '1319,3319,13619,13689,3369,13889,33889,244', '', '0.00', '0.00', '', '    - USD', '', '0071', '', '0.00', '0.00'),
(817, 'DNN', '05', '248', '  2. Tài sản dài hạn khác', '  2. Other long-term assets', '242', '', '0.00', '0.00', '', '    - ....', '', '0072', '', '0.00', '0.00'),
(818, 'DNN', '05', '249', '  3. Dự phòng phải thu dài hạn khó đòi (*)', '  3. Provision for devaluation of long-term securities investment (*)', '15929', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00');
INSERT INTO `cdketoan` (`id`, `chedokt`, `kyhieu`, `masc`, `tentsc`, `tentscu`, `tk1`, `tmtsc`, `tscd`, `tscc`, `masn`, `tentsn`, `tentsnu`, `tk2`, `tmtsn`, `tsnd`, `tsnc`) VALUES
(819, 'DNN', '05', '250*', 'TỔNG CỘNG TÀI SẢN  (250 = 100 + 200)', 'TOTAL ASSETS (270 = 100 + 200)', '1-16-129-139-159,2-214-229,33-335', '', '0.00', '0.00', '   *', '   CỘNG TÀI SẢN NGOÀI BẢNG', ' TOTAL OFF BALANCE SHEET', '00', '', '0.00', '0.00'),
(820, 'DNN', '10', '100*', 'A - TÀI SẢN NGẮN HẠN (100) = 110+120+130+140+150', 'A - CURRENT ASSETS (100) = 110+120+130+140+150', '1-16-129-159-15929-1319-139-1399-13619-13689-13889,33-335-3369-33889-3319,35', '', '0.00', '0.00', '300*', 'A - NỢ PHẢI TRẢ  (300 = 310 + 320)', 'A - LIABILITIES (300 = 310 + 320)', '3,13-139,14,431', '', '0.00', '0.00'),
(821, 'DNN', '10', '110*', 'I. Tiền và các khoản tương đương tiền', 'I. Cash and equivalentce', '11,12119,12129,12819,12889', 'III.0', '0.00', '0.00', '310*', 'I. Nợ ngắn hạn', 'I. Current liabilities', '31,33-3319-3369-3359-33889-3387,353,431,352-3529,13-139-13619-13689-1319-13889,1', '', '0.00', '0.00'),
(822, 'DNN', '10', '120*', 'II. Các khoản đầu tư tài chính ngắn hạn', 'II. Short-term financial investments', '12-129-12119-12129-12819-12889,159-1591', 'III.0', '0.00', '0.00', '311', '  1. Vay và nợ ngắn hạn', '  1. Short-term loan and borrowing', '311,315', '', '0.00', '0.00'),
(823, 'DNN', '10', '121', '  1. Đầu tư ngắn hạn', '  1. Short-term securities investments', '121-12119-12129,128-12819-12889', '', '0.00', '0.00', '312', '  2. Phải trả người bán', '  2. Trade payables', '331-3319', '', '0.00', '0.00'),
(824, 'DNN', '10', '129', '  2. Dự phòng giảm giá chứng khoán đầu tư ngắn hạn (*)', '  2. Provision for devaluation of short-term securities investment (*)', '1591,129', '', '0.00', '0.00', '313', '  3. Người mua trả tiền trước', '  3. Advance from customers', '131-1319', '', '0.00', '0.00'),
(825, 'DNN', '10', '', '', '', '', '', '0.00', '0.00', '314', '  4. Thuế và các khoản phải nộp Nhà nước', '  4. Taxes and payables to State Budget', '133,333', 'III.0', '0.00', '0.00'),
(826, 'DNN', '10', '130*', 'III. Các khoản phải thu', 'III. Account receivable', '13-133-139-1319-13619-13689-13889,1592-15929,33-333-335-3369-33889-3319,35', '', '0.00', '0.00', '315', '  5. Phải trả người lao động', '  5. Payables to employees', '334', '', '0.00', '0.00'),
(827, 'DNN', '10', '131', '  1. Phải thu khách hàng', '  1. Trade receivable', '131-1319', '', '0.00', '0.00', '316', '  6. Chi phí phải trả', '  6. Accrued expenses', '335-3359', '', '0.00', '0.00'),
(828, 'DNN', '10', '132', '  2. Trả trước cho người bán', '  2. Advances to suppliers', '331-3319', '', '0.00', '0.00', '318', '  7. Các khoản phải trả, phải nộp khác', '  7. Other payables', '338-33889-3387,14,138-13889,337,336-3369,136-13619-13689', '', '0.00', '0.00'),
(829, 'DNN', '10', '138', '  3. Các khoản phải thu khác', '  3. Other receivables', '136-13619-13689,336-3369,138-13889,338-33889,334,337,35', '', '0.00', '0.00', '319', '  8. Dự phòng phải trả ngắn hạn', '  8. Provision for short-term payables', '352-3529', '', '0.00', '0.00'),
(830, 'DNN', '10', '139', '  4. Dự phòng các khoản phải thu khó đòi (*)', '  4. Provision for doubtful debts (*)', '1592-15929,139', '', '0.00', '0.00', '323', '  9. Quỹ khen thưởng, phúc lợi', '  9. Bonus and welfare funds', '353,431', '', '0.00', '0.00'),
(831, 'DNN', '10', '', '', '', '', '', '0.00', '0.00', '320*', 'II. Nợ dài hạn', 'II. Long-term liabilities', '3319,3369,13619,13689,1319,13889,3359,33889,34,351,3529,3387,356', '', '0.00', '0.00'),
(832, 'DNN', '10', '140*', 'IV. Hàng tồn kho', 'IV. Inventories', '15-1593', '', '0.00', '0.00', '321', '  1. Vay và nợ dài hạn', '  1. Long-term loan and brrowings', '341,342,343', '', '0.00', '0.00'),
(833, 'DNN', '10', '141', '  1. Hàng tồn kho', '  1. Inventories', '151,152,153,154,155,156,157,158', 'III.0', '0.00', '0.00', '322', '  2. Quỹ dự phòng trợ cấp mất việc làm', '  2. Provision for unemployment allowance', '351', '', '0.00', '0.00'),
(834, 'DNN', '10', '149', '  2. Dự phòng giảm giá hàng tồn kho (*)', '  2. Provision for inventories (*)', '1593,159', '', '0.00', '0.00', '328', '  3. Phải trả  ,phải nộp dài hạn khác', '  3. Long-term loan and brrowings', '1319,13889,3359,33889,344,3319,3369,13619,13689', '', '0.00', '0.00'),
(835, 'DNN', '10', '', '', '', '', '', '0.00', '0.00', '329', '  4. Dự phòng phải trả dài hạn', '  4. Provision for long-term payables', '3529', '', '0.00', '0.00'),
(836, 'DNN', '10', '', '', '', '', '', '0.00', '0.00', '338', '  5. Doanh thu chưa thực hiện', '  5. Doanh thu chŸa th¨c hi¬n', '3387', '', '0.00', '0.00'),
(837, 'DNN', '10', '150*', 'V. Tài sản ngắn hạn khác', 'V. Other current assets', '142,133,333,141,144', '', '0.00', '0.00', '339', '  6. Quỹ phát triển khoa học và công nghệ', '  6. Quñ ph t triŽn khoa h”c v… c“ng ngh¬', '356', '', '0.00', '0.00'),
(838, 'DNN', '10', '151', '  1. Thuế GTGT được khấu trừ', '  1. VAT deductibles', '133', '', '0.00', '0.00', '400*', 'B - VỐN CHỦ SỞ HỮU (400 = 410 + 430)', 'B - OWNER`S EQUITY (400 = 410 + 430)', '4-431,412,413,421,419,461', '', '0.00', '0.00'),
(839, 'DNN', '10', '152', '  2. Thuế và các khoản khác phải thu Nhà nước', '  2. Tax and receivables from budget', '333', '', '0.00', '0.00', '410*', 'I. Vốn chủ sở hữu', 'I. Equity', '41-431,42,44,412,413,421,419', 'III.0', '0.00', '0.00'),
(840, 'DNN', '10', '158', '  3. Tài sản ngắn hạn khác', '  3. Other current assets', '141,142,144', '', '0.00', '0.00', '411', '  1. Vốn đầu tư của chủ sở hữu', '  1. Paid-in capital', '4111', '', '0.00', '0.00'),
(841, 'DNN', '10', '', '', '', '', '', '0.00', '0.00', '412', '  2. Thặng dư vốn cổ phần', '  2. Paid-in capital in excess of par value', '4112', '', '0.00', '0.00'),
(842, 'DNN', '10', '200*', 'B - TÀI SẢN DÀI HẠN', 'B - NON-CURRENT ASSETS', '1319,3319,13619,13689,3369,13889,33889,2-214-229,15929', '', '0.00', '0.00', '413', '  3. Vốn khác của chủ sở hữu', '  3. Other padi-in capital', '4118', '', '0.00', '0.00'),
(843, 'DNN', '10', '', '  (200 = 210 + 220 + 230 + 240 )', '  (200 = 210 + 220 + 230 + 240 )', '', '', '0.00', '0.00', '414', '  4. Cổ phiếu ngân quỹ (*)', '  4. Treasury stocks (*)', '419', '', '0.00', '0.00'),
(844, 'DNN', '10', '', '', '', '', '', '0.00', '0.00', '415', '  5. Chênh lệch tỷ giá hối đoái', '  5. Foreign exchange difference', '412,413', '', '0.00', '0.00'),
(845, 'DNN', '10', '210*', 'I. Tài sản cố định', 'I. Fixed assets', '21-217,241,214-2147', 'III.0', '0.00', '0.00', '416', '  6. Quỹ khác thuộc vốn chủ sở hữu', '  6. Other funds', '418,414,415,441', '', '0.00', '0.00'),
(846, 'DNN', '10', '211', '  1 - Nguyên giá', '   1. Historical cost', '211,212,213', '', '0.00', '0.00', '417', '  7. Lợi nhuận sau thuế chưa phân phối', '  7. Undistributed earnings', '421', '', '0.00', '0.00'),
(847, 'DNN', '10', '212', '  2 - Giá trị hao mòn lũy kế (*)', '   2. Accumulated depreciation (*)', '214-2147', '', '0.00', '0.00', '422', '  8. Quỹ hổ trợ sắp xếp doanh nghiệp', '  8. Quñ h™ trø sép x‰p doanh nghi¬p', '417', '', '0.00', '0.00'),
(848, 'DNN', '10', '213', '  3. Chi phí xây dựng cơ bản dở dang', '   3. Construction in progress', '241', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(849, 'DNN', '10', '', '', '', '', '', '0.00', '0.00', '440*', 'TỔNG CỘNG NGUỒN VỐN (440 = 300 + 400)', 'TOTAL RESOURCE (440 = 300 + 400)', '3,13-139,14,4,412,413,421,431,419,461', '', '0.00', '0.00'),
(850, 'DNN', '10', '220*', 'II. Bất động sản đầu tư', 'III. Real eatate investment', '217,2147', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(851, 'DNN', '10', '221', '      - Nguyên giá', '   1. Historical cost', '217', '', '0.00', '0.00', '', '                 CÁC CHỈ TIÊU', '', '', '', '0.00', '0.00'),
(852, 'DNN', '10', '222', '      - Giá trị hao mòn lũy kế (*)', '   2. Accumulated depreciation (*)', '2147', '', '0.00', '0.00', '', '   NGOÀI BẢNG CÂN ĐỐI KÊ TOÁN', '                OFF BALANCE SHEET ITEMS', '', '', '0.00', '0.00'),
(853, 'DNN', '10', '230*', 'III. Các khoản đầu tư tài chính dài hạn', 'IV. Long-term financial investment', '22-229', 'III.0', '0.00', '0.00', '', '  1. Tài sản thuê ngoài', '  1. Operating lease assets', '001', '', '0.00', '0.00'),
(854, 'DNN', '10', '231', '  1. Đầu tư tài chính dài hạn', '  1. Investment in associates and interest in Joint Ventures', '221,222,223,228', '', '0.00', '0.00', '', '  2. Vật tư, hàng hóa nhận giữ hộ, nhận gia công', '  2. Goods held under trust or for processing', '002', '', '0.00', '0.00'),
(855, 'DNN', '10', '239', '  2. Dự phòng giảm giá đầu tư tài chính dài hạn (*)', '  2. Provision for devaluation of long-term securities investment (*)', '229', '', '0.00', '0.00', '', '  3. Hàng hóa nhận bán hộ, nhận ký gửi ,ký cược', '  3. Goods received', '003', '', '0.00', '0.00'),
(856, 'DNN', '10', '', '', '', '', '', '0.00', '0.00', '', '  4. Nợ khó đòi đã xử lý', '  4. Bad debts written off', '004', '', '0.00', '0.00'),
(857, 'DNN', '10', '240*', 'IV. Tài sản dài hạn khác', 'V. Other long-term assets', '1319,3319,13619,13689,3369,13889,33889,244,242,15929', '', '0.00', '0.00', '', '  5. Ngoại tệ các loại', '  5. Foreign currencies', '007', '', '0.00', '0.00'),
(858, 'DNN', '10', '241', '  1. Phải thu dài hạn khác', '  1. Long-term prepayment', '1319,3319,13619,13689,3369,13889,33889,244', '', '0.00', '0.00', '', '    - USD', '', '0071', '', '0.00', '0.00'),
(859, 'DNN', '10', '248', '  2. Tài sản dài hạn khác', '  2. Other long-term assets', '242', '', '0.00', '0.00', '', '    - ....', '', '0072', '', '0.00', '0.00'),
(860, 'DNN', '10', '249', '  3. Dự phòng phải thu dài hạn khó đòi (*)', '  3. Provision for devaluation of long-term securities investment (*)', '15929', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(861, 'DNN', '10', '250*', 'TỔNG CỘNG TÀI SẢN  (250 = 100 + 200)', 'TOTAL ASSETS (270 = 100 + 200)', '1-16-129-139-159,2-214-229,33-335,35', '', '0.00', '0.00', '   *', '   CỘNG TÀI SẢN NGOÀI BẢNG', ' TOTAL OFF BALANCE SHEET', '00', '', '0.00', '0.00'),
(862, 'DNN', '14', '100**', 'A - TÀI SẢN NGẮN HẠN (100) = 110+120+130+140+150', 'A - CURRENT ASSETS (100) = 110+120+130+140+150', '110+120+130+140+150', '', '9.00', '0.00', '400**', 'C - NỢ PHẢI TRẢ  (400 = 410 + 420)', 'A - LIABILITIES ( 400 = 410 + 420 )', '410+420', '', '0.00', '0.00'),
(863, 'DNN', '14', '110*', 'I. Tiền và các khoản tương đương tiền', 'I. Cash and equivalentce', '11', 'V.01', '3.00', '0.00', '410*', 'I. Nợ ngắn hạn', 'I. Current liabilities', '411+412+413+414+415+416+417+418', '', '0.00', '0.00'),
(864, 'DNN', '14', '120*', 'II. Đầu tư tài chính ngắn hạn', 'II. Short-term financial investments', '121+122+123', 'V.02', '4.00', '0.00', '411', '  1. Phải trả người bán ngắn hạn', '  1. Trade payables', '331-3319', '', '0.00', '0.00'),
(865, 'DNN', '14', '121', '  1. Chứng khoán kinh doanh', '  1. Short-term securities investments', '121', 'V.02.', '3.00', '0.00', '412', '  2. Người mua trả tiền trước ngắn hạn', '  2. Advance from customers', '131-1319', '', '0.00', '0.00'),
(866, 'DNN', '14', '122', '  2. Dự phòng giảm giá Chứng khoán kinh doanh (*)', '  2. Provision for devaluation of short-term securities investment (*)', '2291', '', '1.00', '0.00', '413', '  3. Thuế và các khoản phải nộp Nhà nước', '  3. Taxes and payables to State Budget', '133,333', '', '0.00', '0.00'),
(867, 'DNN', '14', '123', '  3. Đầu tư nắm giữ đến ngày đáo hạn', '', '128-12819-12829-12839-12889', 'V.02.', '0.00', '0.00', '414', '  4. Phải trả người lao động', '  4. Payables to employees', '334', '', '0.00', '0.00'),
(868, 'DNN', '14', '130*', 'III. Các khoản phải thu ngắn hạn', 'III. Account receivable', '131+132+133+134+135', '', '1.00', '0.00', '415', '  5. Phải trả ngắn hạn khác', '  5. Other payables', '337,335-3359,338-33889-33879,138-13889,14,357,171,336-3361-33689,136', '', '0.00', '0.00'),
(869, 'DNN', '14', '131', '  1. Phải thu ngắn hạn của khách hàng', '  1. Trade receivable', '131-1319', '', '0.00', '0.00', '416', '  6. Vay và nợ thuê tài chính ngắn hạn', '', '341-34119-34129', '', '0.00', '0.00'),
(870, 'DNN', '14', '132', '  2. Trả trước cho người bán ngắn hạn', '  2. Advances to suppliers', '331-3319', '', '1.00', '0.00', '417', '  7. Dự phòng phải trả ngắn hạn', '  7. Provision for short-term payables', '352-3529', '', '0.00', '0.00'),
(871, 'DNN', '14', '133', '  3. Phải thu ngắn hạn khác', '  3. Other receivables', '1380,1385,1388-13889,338-33889,334,352,356,357,337,136-1361-13689,336-33689,341', '', '0.00', '0.00', '418', '  8. Quỹ khen thưởng, phúc lợi', '  8. Bonus and welfare funds', '353', '', '0.00', '0.00'),
(872, 'DNN', '14', '134', '  4. Tài sản thiếu chờ xử lý', '', '1381', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(873, 'DNN', '14', '135', '  5. Dự phòng phải thu ngắn hạn khó đòi (*)', '  5. Provision for doubtful debts (*)', '2293-22939', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(874, 'DNN', '14', '140*', 'IV. Hàng tồn kho', 'IV. Inventories', '141+142', '', '1.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(875, 'DNN', '14', '141', '  1. Hàng tồn kho', '  1. Inventories', '15-1549-15349', '', '1.00', '0.00', '420*', 'II. Nợ dài hạn', 'II. Long-term liabilities', '421+422+423+424+425+426+427', '', '0.00', '0.00'),
(876, 'DNN', '14', '142', '  2. Dự phòng giảm giá hàng tồn kho (*)', '  2. Provision for inventories (*)', '2294', '', '0.00', '0.00', '421', '  1. Phải trả người bán dài hạn', '  1. Long-term trade payables', '3319', '', '0.00', '0.00'),
(877, 'DNN', '14', '150*', 'V. Tài sản ngắn hạn khác', 'V. Other current assets', '151+152', '', '0.00', '0.00', '422', '  2. Người mua trả tiền trước dài hạn', '', '1319', '', '0.00', '0.00'),
(878, 'DNN', '14', '151', '  1. Thuế GTGT được khấu trừ', '  1. VAT deductibles', '133', '', '0.00', '0.00', '423', '  3. Phải trả nội bộ về vốn kinh doanh', '', '3361', '', '0.00', '0.00'),
(879, 'DNN', '14', '152', '  2. Tài sản ngắn hạn khác', '  2. Other current assets', '14,171,333,242-2429,335', '', '0.00', '0.00', '424', '  4. Phải trả dài hạn khác', '  4. Other long-term payables', '13889,3359,33889,344,33689,13689,33879,343,347', '', '0.00', '0.00'),
(880, 'DNN', '14', '', '', '', '', '', '0.00', '0.00', '425', '  5. Vay và nợ thuê tài chính dài hạn', '  5. Long-term loan and brrowings', '34119,34129', '', '0.00', '0.00'),
(881, 'DNN', '14', '200**', 'B - TÀI SẢN DÀI HẠN', 'B - NON-CURRENT ASSETS', '210+220+230+240+250+260', '', '2.00', '0.00', '426', '  6. Dự phòng phải trả dài hạn', '  6. Provision for long-term payables', '3529', '', '0.00', '0.00'),
(882, 'DNN', '14', '', '  (200 = 210 + 220 + 230 + 240 + 250 + 260)', '  (200 = 210 + 220 + 230 + 240 + 250 + 260)', '', '', '0.00', '0.00', '427', '  7. Quỹ phát triển Khoa học và Công nghệ', '', '356', '', '0.00', '0.00'),
(883, 'DNN', '14', '210*', 'I- Các khoản phải thu dài hạn', 'I- Long-term receivables', '211+212+213+214+215', '', '2.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(884, 'DNN', '14', '211', '  1. Phải thu dài hạn của khách hàng', '  1. Long-term receivables - Trading', '1319', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(885, 'DNN', '14', '212', '  2. Trả trước cho người  bán dài hạn', '', '3319', '', '2.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(886, 'DNN', '14', '213', '  3. Vốn kinh doanh ở đơn vị trực thuộc', '  3. Capital in subsidiaries', '1361', '', '0.00', '0.00', '500*', 'D - VỐN CHỦ SỞ HỮU', 'B - OWNER`S EQUITY', '511+512+513+514+515+516+517', '', '0.00', '0.00'),
(887, 'DNN', '14', '214', '  4. Phải thu dài hạn khác', '  4. Other long-term receivables', '13889,33889,13689,33689', '', '0.00', '0.00', '', '    ( 500 = 511+512+513+514+515+516+517 )', '    ( 500 = 511+512+513+514+515+516+517 )', '', '', '0.00', '0.00'),
(888, 'DNN', '14', '215', '  5. Dự phòng phải thu dài hạn khó đòi (*)', '  5. Provisions for long-term bad debts (*)', '22939', '', '0.00', '0.00', '511', '  1. Vốn góp của chủ sở hữu', '  1. Equity', '4111', '', '0.00', '0.00'),
(889, 'DNN', '14', '220*', 'II. Tài sản cố định', 'II. Fixed assets', '221+222', '', '0.00', '0.00', '512', '  2. Thặng dư vốn cổ phần', '  2. Paid-in capital in excess of par value', '4112', '', '0.00', '0.00'),
(890, 'DNN', '14', '221', '      - Nguyên giá', '     - Historical cost', '211,212,213', '', '0.00', '0.00', '513', '  3. Vốn khác của chủ sở hữu', '  3. Other padi-in capital', '4113,4118', '', '0.00', '0.00'),
(891, 'DNN', '14', '222', '      - Giá trị hao mòn lũy kế (*)', '     - Accumulated depreciation (*)', '2141,2142,2143', '', '0.00', '0.00', '514', '  4. Cổ phiếu quỹ (*)', '  4. Treasury stocks (*)', '419', '', '0.00', '0.00'),
(892, 'DNN', '14', '230*', 'III. Bất động sản đầu tư', 'III. Real eatate investment', '231+232', '', '0.00', '0.00', '515', '  5. Chênh lệch tỷ giá hối đoái', '  5. Foreign exchange difference', '413', '', '0.00', '0.00'),
(893, 'DNN', '14', '231', '      - Nguyên giá', '     - Historical cost', '217', '', '0.00', '0.00', '516', '  6. Quỹ khác thuộc vốn chủ sở hữu', '  6. Other funds', '412,414,417,418,441,46', '', '0.00', '0.00'),
(894, 'DNN', '14', '232', '      - Giá trị hao mòn lũy kế (*)', '     - Accumulated depreciation (*)', '2147', '', '0.00', '0.00', '517', '  7. Lợi nhuận sau thuế chưa phân phối', '  7. Undistributed earnings', '421', '', '0.00', '0.00'),
(895, 'DNN', '14', '240*', 'IV. Xây dựng cơ bản dở dang', 'IV. Construction in progress', '241,1549', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(896, 'DNN', '14', '250*', 'V.  Đầu tư tài chính dài hạn', ' V. Long-term financial investment', '251+252+253', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(897, 'DNN', '14', '251', '  1. Đầu tư góp vốn vào đơn vị khác', '  1. Other long-term investment', '221,222,223,228', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(898, 'DNN', '14', '252', '  2. Dự phòng tổn thất đầu tư vào đơn vị khác (*)', '  2. Provision for devaluation of long-term securities investment (*)', '2292', '', '0.00', '0.00', '600**', 'TỔNG CỘNG NGUỒN VỐN', 'TOTAL RESOURCE', '400+500', '', '0.00', '0.00'),
(899, 'DNN', '14', '253', '  3. Đầu tư nắm giữ đến ngày đáo hạn dài hạn', '', '12819,12829,12839,12889', '', '0.00', '0.00', '', '          (600 = 400 + 500)', '  (600 = 400 + 500)', '', '', '0.00', '0.00'),
(900, 'DNN', '14', '260*', 'VI. Tài sản dài hạn khác', 'VI. Other long-term assets', '243,244,2429,15349', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(901, 'DNN', '14', '', '', '', '', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(902, 'DNN', '14', '300**', 'TỔNG CỘNG TÀI SẢN  (300 = 100 + 200)', 'TOTAL ASSETS  (300 = 100 + 200)', '100+200', '', '11.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(903, 'DNN', '16', '110*', 'I. Tiền và các khoản tương đương tiền', 'I. Cash and equivalentce', '11', '', '3.00', '0.00', '300*', 'I. Nợ phải trả', 'I. Current liabilities', '311+312+313+314+315+316+317+318+319+320', '', '0.00', '0.00'),
(904, 'DNN', '16', '120*', 'II. Đầu tư tài chính', 'II. Short-term financial investments', '121,128,221,222,223,228', '', '4.00', '0.00', '311', '  1. Phải trả người bán', '  1. Trade payables', '331', '', '0.00', '0.00'),
(905, 'DNN', '16', '121', '  1. Chứng khoán kinh doanh', '  1. Short-term securities investments', '121', '', '3.00', '0.00', '312', '  2. Người mua trả tiền trước', '  2. Advance from customers', '131', '', '0.00', '0.00'),
(906, 'DNN', '16', '122', '  2. Đầu tư nắm giữ đến ngày đáo hạn', '  2. Provision for devaluation of short-term securities investment (*)', '128', '', '1.00', '0.00', '313', '  3. Thuế và các khoản phải nộp Nhà nước', '  3. Taxes and payables to State Budget', '133,333', '', '0.00', '0.00'),
(907, 'DNN', '16', '123', '  3. Đầu tư góp vốn vào đơn vị khác', '', '221,222,223,228', '', '0.00', '0.00', '314', '  4. Phải trả người lao động', '  4. Payables to employees', '334', '', '0.00', '0.00'),
(908, 'DNN', '16', '130*', 'III. Các khoản phải thu ngắn hạn', 'III. Account receivable', '131+132+133+134+135', '', '1.00', '0.00', '315', '  5. Phải trả khác', '  5. Other payables', '337,335,338,138,14,357,171,336-3361,136,344,343,347', '', '0.00', '0.00'),
(909, 'DNN', '16', '131', '  1. Phải thu của khách hàng', '  1. Trade receivable', '131', '', '0.00', '0.00', '316', '  6. Vay và nợ thuê tài chính', '', '341', '', '0.00', '0.00'),
(910, 'DNN', '16', '132', '  2. Trả trước cho người bán', '  2. Advances to suppliers', '331', '', '1.00', '0.00', '317', '  7. Phải trả nội bộ về vốn kinh doanh', '', '3361', '', '0.00', '0.00'),
(911, 'DNN', '16', '133', '  3. Vốn kinh doanh ở đơn vị trực thuộc', '  3. Capital in subsidiaries', '1361', '', '0.00', '0.00', '318', '  8. Dự phòng phải trả', '  7. Provision for short-term payables', '352', '', '0.00', '0.00'),
(912, 'DNN', '16', '134', '  4. Phải thu khác', '  4. Other receivables', '138-1381-13889,338,334,352,356,357,337,136-1361,336,341', '', '0.00', '0.00', '319', '  9. Quỹ khen thưởng, phúc lợi', '  8. Bonus and welfare funds', '353', '', '0.00', '0.00'),
(913, 'DNN', '16', '135', '  5. Tài sản thiếu chờ xử lý', '  5. Provision for doubtful debts (*)', '1381', '', '0.00', '0.00', '320', ' 10. Quỹ phát triển Khoa học và Công nghệ', '', '356', '', '0.00', '0.00'),
(914, 'DNN', '16', '140*', 'IV. Hàng tồn kho', 'IV. Inventories', '15', '', '1.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(915, 'DNN', '16', '150*', 'V. Tài sản cố định và bất động sản đầu tư', ' V. Fixed assets', '211,212,213,217,2141,2142,2143,2147', '', '0.00', '0.00', '400*', 'II - Vốn chủ sở hữu', '   Equity', '411+412+413+414+415+416+417', '', '0.00', '0.00'),
(916, 'DNN', '16', '160*', 'VI. Xây dựng cơ bản dở dang', 'VI. Construction in progress', '241', '', '0.00', '0.00', '411', '  1. Vốn góp của chủ sở hữu', '  1. Equity', '4111', '', '0.00', '0.00'),
(917, 'DNN', '16', '170*', 'VII. Tài sản khác', 'VII. Other current assets', '14,171,333,242,243,244,133,229,335', '', '0.00', '0.00', '412', '  2. Thặng dư vốn cổ phần', '  2. Paid-in capital in excess of par value', '4112', '', '0.00', '0.00'),
(918, 'DNN', '16', '171', '  1. Thuế GTGT được khấu trừ', '  1. VAT deductibles', '133', '', '0.00', '0.00', '413', '  3. Vốn khác của chủ sở hữu', '  3. Other padi-in capital', '4113,4118', '', '0.00', '0.00'),
(919, 'DNN', '16', '172', '  2. Tài sản khác', '  2. Other long-term assets', '14,171,333,242,243,244,229,335', '', '0.00', '0.00', '414', '  4. Cổ phiếu quỹ (*)', '  4. Treasury stocks (*)', '419', '', '0.00', '0.00'),
(920, 'DNN', '16', '', '', '', '', '', '0.00', '0.00', '415', '  5. Chênh lệch tỷ giá hối đoái', '  5. Foreign exchange difference', '413', '', '0.00', '0.00'),
(921, 'DNN', '16', '', '', '', '', '', '0.00', '0.00', '416', '  6. Quỹ khác thuộc vốn chủ sở hữu', '  6. Other funds', '412,414,417,418,441,46', '', '0.00', '0.00'),
(922, 'DNN', '16', '', '', '', '', '', '0.00', '0.00', '417', '  7. Lợi nhuận sau thuế chưa phân phối', '  7. Undistributed earnings', '421', '', '0.00', '0.00'),
(923, 'DNN', '16', '', '', '', '', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(924, 'DNN', '16', '200**', '       TỔNG CỘNG TÀI SẢN', '                TOTAL ASSETS', '110+120+130+140+150+160+170', '', '0.00', '0.00', '500**', 'TỔNG CỘNG NGUỒN VỐN', 'TOTAL RESOURCE', '300+400', '', '0.00', '0.00'),
(925, 'DNN', '16', '', '( 110+120+130+140+150+160+170 )', '( 110+120+130+140+150+160+170 )', '', '', '0.00', '0.00', '', '          (500 = 300 + 400)', ' (500 = 300 + 400)', '', '', '0.00', '0.00'),
(926, 'DNN', '15', '110*', 'I.Tiền và các khoản tương đương tiền', 'I. Cash and equivalentce', '11', 'V.01', '3.00', '0.00', '300*', 'I - NỢ PHẢI TRẢ', 'I. Current liabilities', '311+312+313+314+315+316+317+318+319+320', '', '0.00', '0.00'),
(927, 'DNN', '15', '120*', 'II. Đầu tư tài chính', 'II. Short-term financial investments', '121+122+123+124', 'V.02', '4.00', '0.00', '311', '  1. Phải trả người bán', '  1. Trade payables', '331', '', '0.00', '0.00'),
(928, 'DNN', '15', '121', '  1. Chứng khoán kinh doanh', '  1. Short-term securities investments', '121', 'V.02.', '3.00', '0.00', '312', '  2. Người mua trả tiền trước', '  2. Advance from customers', '131', '', '0.00', '0.00'),
(929, 'DNN', '15', '122', '  2. Đầu tư nắm giữ đến ngày đáo hạn', '  2. Provision for devaluation of short-term securities investment (*)', '128', '', '1.00', '0.00', '313', '  3. Thuế và các khoản phải nộp Nhà nước', '  3. Taxes and payables to State Budget', '133,333', '', '0.00', '0.00'),
(930, 'DNN', '15', '123', '  3. Đầu tư góp vốn vào đơn vị khác', '', '221,222,223,228', 'V.02.', '0.00', '0.00', '314', '  4. Phải trả người lao động', '  4. Payables to employees', '334', '', '0.00', '0.00'),
(931, 'DNN', '15', '124', '  4. Dự phòng tổn thất đầu tư tài chính (*)', '', '2291,2292', '', '0.00', '0.00', '315', '  5. Phải trả khác', '', '337,335,338,138,14,357,171,336-3361,136,344,343,347', '', '0.00', '0.00'),
(932, 'DNN', '15', '130*', 'III. Các khoản phải thu', 'III. Account receivable', '131+132+133+134+135+136', '', '1.00', '0.00', '316', '  6. Vay và nợ thuê tài chính', '  5. Other payables', '341', '', '0.00', '0.00'),
(933, 'DNN', '15', '131', '  1. Phải thu của khách hàng', '  1. Trade receivable', '131', '', '0.00', '0.00', '317', '  7. Phải trả nội bộ về vốn kinh doanh', '', '3361', '', '0.00', '0.00'),
(934, 'DNN', '15', '132', '  2. Trả trước cho người bán', '  2. Advances to suppliers', '331', '', '1.00', '0.00', '318', '  8. Dự phòng phải trả', '  7. Provision for short-term payables', '352', '', '0.00', '0.00'),
(935, 'DNN', '15', '133', '  3. Vốn kinh doanh ở đơn vị trực thuộc', '  3. Other receivables', '1361', '', '0.00', '0.00', '319', '  9. Quỹ khen thưởng, phúc lợi', '  8. Bonus and welfare funds', '353', '', '0.00', '0.00'),
(936, 'DNN', '15', '134', '  4. Phải thu khác', '', '138-1381-13889,338,334,352,356,357,337,136-1361,336,341', '', '0.00', '0.00', '320', '10. Quỹ phát triển Khoa học và Công nghệ', '', '356', '', '0.00', '0.00'),
(937, 'DNN', '15', '135', '  5. Tài sản thiếu chờ xử lý', 'V. Other current assets', '1381', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(938, 'DNN', '15', '136', '  6. Dự phòng phải thu khó đòi (*)', '  1. VAT deductibles', '2293', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(939, 'DNN', '15', '140*', 'IV. Hàng tồn kho', '  2. Other current assets', '141+142', '', '0.00', '0.00', '400*', 'II - VỐN CHỦ SỞ HỮU', '  4. Other long-term payables', '411+412+413+414+415+416+417', '', '0.00', '0.00'),
(940, 'DNN', '15', '141', '  1. Hàng tồn kho', '  3. Capital in subsidiaries', '15', '', '0.00', '0.00', '', '    ( 400 = 411+412+413+414+415+416+417 )', 'B - OWNER`S EQUITY', '', '', '0.00', '0.00'),
(941, 'DNN', '15', '142', '  2. Dự phòng giảm giá hàng tồn kho (*)', '  4. Other long-term receivables', '2294', '', '0.00', '0.00', '411', '  1. Vốn góp của chủ sở hữu', '    ( 500 = 511+512+513+514+515+516+517 )', '4111', '', '0.00', '0.00'),
(942, 'DNN', '15', '150*', 'V. Tài sản cố định', 'II. Fixed assets', '151+152', '', '0.00', '0.00', '412', '  2. Thặng dư vốn cổ phần', '  2. Paid-in capital in excess of par value', '4112', '', '0.00', '0.00'),
(943, 'DNN', '15', '151', '      - Nguyên giá', '     - Historical cost', '211,212,213', '', '0.00', '0.00', '413', '  3. Vốn khác của chủ sở hữu', '  3. Other padi-in capital', '4113,4118', '', '0.00', '0.00'),
(944, 'DNN', '15', '152', '      - Giá trị hao mòn lũy kế (*)', '     - Accumulated depreciation (*)', '2141,2142,2143', '', '0.00', '0.00', '414', '  4. Cổ phiếu quỹ (*)', '  4. Treasury stocks (*)', '419', '', '0.00', '0.00'),
(945, 'DNN', '15', '160*', 'VI. Bất động sản đầu tư', 'III. Real eatate investment', '161+162', '', '0.00', '0.00', '415', '  5. Chênh lệch tỷ giá hối đoái', '  5. Foreign exchange difference', '413', '', '0.00', '0.00'),
(946, 'DNN', '15', '161', '      - Nguyên giá', '     - Historical cost', '217', '', '0.00', '0.00', '416', '  6. Quỹ khác thuộc vốn chủ sở hữu', '  6. Other funds', '412,414,417,418,441,46', '', '0.00', '0.00'),
(947, 'DNN', '15', '162', '      - Giá trị hao mòn lũy kế (*)', '     - Accumulated depreciation (*)', '2147', '', '0.00', '0.00', '417', '  7. Lợi nhuận sau thuế chưa phân phối', '  7. Undistributed earnings', '421', '', '0.00', '0.00'),
(948, 'DNN', '15', '170*', 'VII. Xây dựng cơ bản dở dang', 'IV. Construction in progress', '241', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(949, 'DNN', '15', '180*', 'V. Tài sản khác', '  1. Other long-term investment', '181+182', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(950, 'DNN', '15', '181', '  1. Thuế GTGT được khấu trừ', '  2. Provision for devaluation of long-term securities investment (*)', '133', '', '0.00', '0.00', '500**', 'TỔNG CỘNG NGUỒN VỐN', 'TOTAL RESOURCE', '300+400', '', '0.00', '0.00'),
(951, 'DNN', '15', '182', '  2. Tài sản khác', '', '14,171,333,242,335,243,244', '', '0.00', '0.00', '', '          (500 = 300 + 400)', '  (600 = 400 + 500)', '', '', '0.00', '0.00'),
(952, 'DNN', '15', '', '', 'VI. Other long-term assets', '', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(953, 'DNN', '15', '200**', 'TỔNG CỘNG TÀI SẢN', 'TOTAL ASSETS  (300 = 100 + 200)', '110+120+130+140+150+160+170+180', '', '11.00', '0.00', '', '', '', '', '', '0.00', '0.00'),
(954, 'DNN', '15', '', '( 200 = 110+120+130+140+150+160+170+180  )', '', '', '', '0.00', '0.00', '', '', '', '', '', '0.00', '0.00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `chitiet`
--

DROP TABLE IF EXISTS `chitiet`;
CREATE TABLE `chitiet` (
  `id` int(10) NOT NULL,
  `ctid` char(12) NOT NULL,
  `diengiai` char(100) NOT NULL,
  `tkno` char(13) NOT NULL,
  `matkno` char(6) NOT NULL,
  `tkco` char(13) NOT NULL,
  `matkco` char(6) NOT NULL,
  `sotien` decimal(15,2) NOT NULL,
  `ngoaite` decimal(15,2) NOT NULL,
  `ctkhac` char(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `connect`
--

DROP TABLE IF EXISTS `connect`;
CREATE TABLE `connect` (
  `id` int(11) NOT NULL,
  `company` varchar(100) CHARACTER SET utf8 NOT NULL,
  `taxcode` varchar(50) CHARACTER SET utf8 NOT NULL,
  `address` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `host` varchar(50) CHARACTER SET utf8 NOT NULL,
  `username` varchar(50) CHARACTER SET utf8 NOT NULL,
  `password` varchar(50) CHARACTER SET utf8 NOT NULL,
  `dataname` varchar(50) CHARACTER SET utf8 NOT NULL,
  `port` varchar(50) CHARACTER SET utf8 NOT NULL DEFAULT '3306',
  `active` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf32;

--
-- Đang đổ dữ liệu cho bảng `connect`
--

INSERT INTO `connect` (`id`, `company`, `taxcode`, `address`, `host`, `username`, `password`, `dataname`, `port`, `active`) VALUES
(23, 'DNTN Tin học Xuân Mai ', '0304529821', '118/63 Bạch Đằng, P24, Bình Thạnh - HCM', 'localhost', 'root', 'nghia@tv', 'ketoan_xuanmai', '3306', 0),
(24, 'Công ty KingMinh', '0304529822', '118/63 Bạch Đằng, P24, Bình Thạnh - HCM', 'localhost', 'root', 'nghia@tv', 'ketoan_kingminh', '3306', 0),
(26, 'Công ty Nhất Nam', '0304529823', '118/63 Bạch Đằng, P24, Bình Thạnh - HCM', 'localhost', 'root', 'nghia@tv', 'ketoan_nhatnam', '3306', 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `connects`
--

DROP TABLE IF EXISTS `connects`;
CREATE TABLE `connects` (
  `id` int(11) NOT NULL,
  `company` varchar(100) CHARACTER SET utf8 NOT NULL,
  `taxcode` varchar(50) CHARACTER SET utf8 NOT NULL,
  `address` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `host` varchar(50) CHARACTER SET utf8 NOT NULL,
  `username` varchar(50) CHARACTER SET utf8 NOT NULL,
  `password` varchar(50) CHARACTER SET utf8 NOT NULL,
  `dataname` varchar(50) CHARACTER SET utf8 NOT NULL,
  `port` varchar(50) CHARACTER SET utf8 NOT NULL DEFAULT '3306',
  `active` tinyint(4) NOT NULL DEFAULT 0,
  `fromdate` date NOT NULL,
  `todate` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Đang đổ dữ liệu cho bảng `connects`
--

INSERT INTO `connects` (`id`, `company`, `taxcode`, `address`, `host`, `username`, `password`, `dataname`, `port`, `active`, `fromdate`, `todate`) VALUES
(1, '1', '1', '1', '1', '1', '1', '1', '3306', 0, '0000-00-00', '0000-00-00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `ctuktoan`
--

DROP TABLE IF EXISTS `ctuktoan`;
CREATE TABLE `ctuktoan` (
  `id` int(10) NOT NULL,
  `ctid` char(12) NOT NULL,
  `soct` char(8) NOT NULL,
  `ngay` date NOT NULL,
  `diengiai` char(100) NOT NULL,
  `tkno` char(13) NOT NULL,
  `matkno` char(6) NOT NULL,
  `tkco` char(13) NOT NULL,
  `matkco` char(6) NOT NULL,
  `sotien` decimal(15,2) NOT NULL,
  `ngaytt` date NOT NULL,
  `hopdong` char(20) NOT NULL,
  `nhom` char(8) NOT NULL,
  `loaitien` char(3) NOT NULL,
  `ngoaite` decimal(15,2) NOT NULL,
  `userid` smallint(6) NOT NULL,
  `ghichu` char(50) NOT NULL,
  `khac` char(3) NOT NULL,
  `sodk` char(10) NOT NULL,
  `mamauhd` char(3) NOT NULL,
  `ngaytra` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `ctuvattu`
--

DROP TABLE IF EXISTS `ctuvattu`;
CREATE TABLE `ctuvattu` (
  `id` int(10) NOT NULL,
  `ctid` char(12) NOT NULL,
  `mahang` char(13) NOT NULL,
  `makho` char(3) NOT NULL,
  `soluong` decimal(16,3) NOT NULL,
  `dongia` decimal(16,3) NOT NULL,
  `sotien` decimal(15,2) NOT NULL,
  `vtkhac` char(3) NOT NULL,
  `ngoaite` decimal(14,2) NOT NULL,
  `doituong` char(5) NOT NULL,
  `giaban` decimal(15,2) NOT NULL,
  `thue` decimal(15,2) NOT NULL,
  `soluong2` decimal(16,3) NOT NULL,
  `doituong2` char(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `customer`
--

DROP TABLE IF EXISTS `customer`;
CREATE TABLE `customer` (
  `id` int(10) NOT NULL,
  `fullname` char(30) NOT NULL,
  `name` char(15) NOT NULL,
  `company` char(100) NOT NULL,
  `address` char(150) NOT NULL,
  `email` char(25) NOT NULL,
  `phone1` char(20) NOT NULL,
  `phone2` char(20) NOT NULL,
  `fax1` char(20) NOT NULL,
  `ghichu` char(35) NOT NULL,
  `group_id` char(3) NOT NULL,
  `maso` char(17) NOT NULL,
  `account` char(20) NOT NULL,
  `bank` char(50) NOT NULL,
  `citibank` char(50) NOT NULL,
  `makhach` char(8) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `dmkhohag`
--

DROP TABLE IF EXISTS `dmkhohag`;
CREATE TABLE `dmkhohag` (
  `id` int(10) NOT NULL,
  `nam` char(4) NOT NULL,
  `mahang` char(13) NOT NULL,
  `makho` char(3) NOT NULL,
  `luongdn` decimal(16,3) NOT NULL,
  `tiendn` decimal(16,2) NOT NULL,
  `luongdk` decimal(16,3) NOT NULL,
  `tiendk` decimal(16,2) NOT NULL,
  `luongnhap` decimal(16,3) NOT NULL,
  `tiennhap` decimal(16,2) NOT NULL,
  `luongxuat` decimal(16,3) NOT NULL,
  `tienxuat` decimal(16,2) NOT NULL,
  `luongck` decimal(16,3) NOT NULL,
  `tienck` decimal(16,2) NOT NULL,
  `giamoi` decimal(16,2) NOT NULL,
  `soluongkk` decimal(16,3) NOT NULL,
  `tienkk` decimal(16,2) NOT NULL,
  `lgccdn` decimal(16,3) NOT NULL,
  `ttccdn` decimal(16,2) NOT NULL,
  `lgcckk` decimal(16,3) NOT NULL,
  `ttcckk` decimal(16,2) NOT NULL,
  `pb100` tinyint(1) NOT NULL,
  `ghichu` char(20) NOT NULL,
  `ngoaite` decimal(13,2) NOT NULL,
  `luongdn2` decimal(16,3) NOT NULL,
  `luongdk2` decimal(16,3) NOT NULL,
  `luongnhap2` decimal(16,3) NOT NULL,
  `luongxuat2` decimal(16,3) NOT NULL,
  `luongck2` decimal(16,3) NOT NULL,
  `thuemua` decimal(16,2) NOT NULL,
  `thueban` decimal(16,2) NOT NULL,
  `tienban` decimal(16,2) NOT NULL,
  `lklnhap` decimal(16,3) NOT NULL,
  `lklxuat` decimal(16,3) NOT NULL,
  `lktnhap` decimal(16,2) NOT NULL,
  `lktxuat` decimal(16,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `dmsodutk`
--

DROP TABLE IF EXISTS `dmsodutk`;
CREATE TABLE `dmsodutk` (
  `id` int(10) NOT NULL,
  `nam` char(4) NOT NULL,
  `sotk` char(13) NOT NULL,
  `tkhoan` char(6) NOT NULL,
  `tentk` char(100) NOT NULL,
  `diachi` char(100) NOT NULL,
  `nodn` decimal(15,2) NOT NULL,
  `codn` decimal(15,2) NOT NULL,
  `nodk` decimal(15,2) NOT NULL,
  `codk` decimal(15,2) NOT NULL,
  `psno` decimal(15,2) NOT NULL,
  `psco` decimal(15,2) NOT NULL,
  `lkpsno` decimal(15,2) NOT NULL,
  `lkpsco` decimal(15,2) NOT NULL,
  `nock` decimal(15,2) NOT NULL,
  `cock` decimal(15,2) NOT NULL,
  `ghichu` longtext NOT NULL,
  `loaitien` char(3) NOT NULL,
  `ngoaite` decimal(13,2) NOT NULL,
  `thuedt` decimal(4,2) NOT NULL,
  `lcheck` tinyint(1) NOT NULL,
  `hanmuc` decimal(15,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `dmtenkho`
--

DROP TABLE IF EXISTS `dmtenkho`;
CREATE TABLE `dmtenkho` (
  `id` int(10) NOT NULL,
  `makho` char(3) NOT NULL,
  `tengoi` char(100) NOT NULL,
  `diachi` char(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `dmtiente`
--

DROP TABLE IF EXISTS `dmtiente`;
CREATE TABLE `dmtiente` (
  `id` int(10) NOT NULL,
  `loaitien` char(3) NOT NULL,
  `tengoi` char(30) NOT NULL,
  `viettat` char(3) NOT NULL,
  `tygia` decimal(15,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `dmtkhoan`
--

DROP TABLE IF EXISTS `dmtkhoan`;
CREATE TABLE `dmtkhoan` (
  `id` int(10) NOT NULL,
  `sotk` char(13) NOT NULL,
  `tkhoan` char(6) NOT NULL,
  `tentk` char(100) NOT NULL,
  `diachi` char(100) NOT NULL,
  `nodn` decimal(15,2) NOT NULL,
  `codn` decimal(15,2) NOT NULL,
  `nodk` decimal(15,2) NOT NULL,
  `codk` decimal(15,2) NOT NULL,
  `psno` decimal(15,2) NOT NULL,
  `psco` decimal(15,2) NOT NULL,
  `lkpsno` decimal(15,2) NOT NULL,
  `lkpsco` decimal(15,2) NOT NULL,
  `nock` decimal(15,2) NOT NULL,
  `cock` decimal(15,2) NOT NULL,
  `ghichu` longtext NOT NULL,
  `loaitien` char(3) NOT NULL,
  `ngoaite` decimal(13,2) NOT NULL,
  `thuedt` decimal(4,2) NOT NULL,
  `lcheck` tinyint(1) NOT NULL,
  `hanmuc` decimal(15,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `hoadon`
--

DROP TABLE IF EXISTS `hoadon`;
CREATE TABLE `hoadon` (
  `id` int(10) NOT NULL,
  `ctid` char(12) NOT NULL,
  `mausohd` char(15) NOT NULL,
  `sohd` char(18) NOT NULL,
  `ngay` date NOT NULL,
  `diengiai` char(100) NOT NULL,
  `thuesuat` char(3) NOT NULL,
  `giaban` decimal(15,2) NOT NULL,
  `thuegtgt` decimal(15,2) NOT NULL,
  `mamauhd` char(3) NOT NULL,
  `sohdong` char(20) NOT NULL,
  `ngayhdong` date NOT NULL,
  `hinhthuctt` char(20) NOT NULL,
  `diemgiao` char(100) NOT NULL,
  `diemnhan` char(100) NOT NULL,
  `sovandon` char(20) NOT NULL,
  `socontaine` char(20) NOT NULL,
  `dvanchuyen` char(100) NOT NULL,
  `dienthoai` char(15) NOT NULL,
  `tygia` decimal(15,2) NOT NULL,
  `masothue` varchar(17) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `ketquakd`
--

DROP TABLE IF EXISTS `ketquakd`;
CREATE TABLE `ketquakd` (
  `id` int(10) NOT NULL,
  `chedokt` char(10) NOT NULL,
  `kyhieu` char(2) NOT NULL,
  `swt` char(3) NOT NULL,
  `maso` char(3) NOT NULL,
  `kyhieu1` char(2) NOT NULL,
  `kyhieu2` char(2) NOT NULL,
  `tminh` char(5) NOT NULL,
  `chitieu` char(80) NOT NULL,
  `chitieuu` char(80) NOT NULL,
  `cachtinh` char(80) NOT NULL,
  `kytruoc` decimal(15,2) NOT NULL,
  `kynay` decimal(15,2) NOT NULL,
  `luyke` decimal(15,2) NOT NULL,
  `luykeno` decimal(15,2) NOT NULL,
  `luykeco` decimal(15,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `ketquakd`
--

INSERT INTO `ketquakd` (`id`, `chedokt`, `kyhieu`, `swt`, `maso`, `kyhieu1`, `kyhieu2`, `tminh`, `chitieu`, `chitieuu`, `cachtinh`, `kytruoc`, `kynay`, `luyke`, `luykeno`, `luykeco`) VALUES
(5953, 'DNL', '98', 'KQ*', '01', '', '', '', ' - Tổng doanh thu', ' - Gross turnover', '51/52,53,333,91', '197936711.00', '37074376658.00', '5645.00', '0.00', '0.00'),
(5954, 'DNL', '98', 'KQ', '02', '', '', '', '   Trong đó : doanh thu hàng xuất khẩu     (51119)', '   of which : turnover of export', '/51119', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5955, 'DNL', '98', 'KQ*', '03', '', '', '', ' - Các khoản giãm trừ ( 04+05+06+07 )', ' - Deductions (04+05+06+07)', 'Z(04+05+06+07)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5956, 'DNL', '98', 'KQ', '04', '', '', '', '   + Chiết khấu', '   + Discounts', '51/521', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5957, 'DNL', '98', 'KQ', '05', '', '', '', '   + Giãm giá', '   + Devaluation', '51/532', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5958, 'DNL', '98', 'KQ', '06', '', '', '', '   + Giá trị hàng bán bị trả lại', '   + Sold goods to be returned', '51/531', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5959, 'DNL', '98', 'KQ', '07', '', '', '', '   + Thuế doanh thu ,xuất khẩu phải nộp', '   + Payables of turnover and export tax', '51/3331,3332,3333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5960, 'DNL', '98', 'KQ*', '10', '', '', '', '1.Doanh thu thuần ( 01-03 )', '1.Net income (01-03)', 'Z(01-03)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5961, 'DNL', '98', 'KQ*', '11', '', '', '', '2.Giá vốn hàng bán', '2.Original rate of sold goods', '91/632', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5962, 'DNL', '98', 'KQ*', '20', '', '', '', '3.Lợi tức gộp ( 10-11)', '3.Gross profit (10-11)', 'Z(10-11)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5963, 'DNL', '98', 'KQ*', '21', '', '', '', '4.Chi phí bán hàng', '4.Sale costs', '91/641', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5964, 'DNL', '98', 'KQ*', '22', '', '', '', '5.Chi phí quản lý doanh nghiệp', '5.Enteprise management costs', '91/642,142', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5965, 'DNL', '98', 'KQ*', '30', '', '', '', '6.Lợi tức thuần từ hoạt động kinh doanh  ( 20-21-22)', '6.Net profit from business  ( 20-21-22)', 'Z(20-21-22)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5966, 'DNL', '98', 'KQ', '31', '', '', '', ' - Thu nhập hoạt động tài chính', ' - Income from financial activities', '/711', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5967, 'DNL', '98', 'KQ', '32', '', '', '', ' - Thuế doanh thu phải nộp', ' - Payables of turnover', '711/333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5968, 'DNL', '98', 'KQ', '33', '', '', '', ' - Chi phí hoạt động tài chính', ' - Costs for financial activities', '91/811', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5969, 'DNL', '98', 'KQ*', '40', '', '', '', '7.Lợi tức hoạt động tài chính ( 31-32 -33)', '7.Profit from financial activities', 'Z(31-32-33)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5970, 'DNL', '98', 'KQ', '41', '', '', '', ' - Các khoản thu nhập bất thường', ' - Unforseen income', '/721', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5971, 'DNL', '98', 'KQ', '42', '', '', '', ' - Thuế doanh thu phải nộp', ' - Payables of turnover', '721/333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5972, 'DNL', '98', 'KQ', '43', '', '', '', ' - Chi phí bất thường', ' - Unforseen costs', '91/821', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5973, 'DNL', '98', 'KQ*', '50', '', '', '', '8.Lợi tức bất thường ( 41-42 -43)', '8.Unforseen profit (41-42)', 'Z(41-42-43)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5974, 'DNL', '98', 'KQ*', '60', '', '', '', '9.Tổng lợi tức trước thuế ( 30+40+50 )', '9.Gross profit before tax (30+40+50)', 'Z(30+40+50)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5975, 'DNL', '98', 'KQ*', '70', '', '', '', '10.Lợi tức phải nộp', '10.Payable profit tax', '421/3334', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5976, 'DNL', '98', 'KQ*', '80', '', '', '', '11.Lợi tức sau thuế ( 60 -70 )', '11.Profit after tax (60-70)', 'Z(60-70)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5977, 'DNL', '--', '---', '--', '', '', '', '----------------------------------------', '----------------------------------------', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5978, 'DNL', '98', 'NS*', '', '', '', '', 'I - Thuế', 'I - Taxes', '/333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5979, 'DNL', '98', 'NS', '', '', '', '', '1. Thuế doanh thu ( hoặc V.A.T )', '1.Turnover tax (or VAT)', '/3331', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5980, 'DNL', '98', 'NS', '', '', '', '', '2. Thuế tiêu thụ đặc biệt', '2.Excise tax', '/3332', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5981, 'DNL', '98', 'NS', '', '', '', '', '3. Thuế xuất ,nhập khẩu', '3.Import and export duties', '/3333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5982, 'DNL', '98', 'NS', '', '', '', '', '4. Thuế lợi tức', '4.Profit tax', '/3334', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5983, 'DNL', '98', 'NS', '', '', '', '', '5. Thu trên vốn', '5.Capital earnings', '/3335', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5984, 'DNL', '98', 'NS', '', '', '', '', '6. Thuế tài nguyên', '6.Land and house tax', '/3336', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5985, 'DNL', '98', 'NS', '', '', '', '', '7. Thuế nhà đất ,tiền thuê đất', '7.Land lease costs', '/3337', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5986, 'DNL', '98', 'NS', '', '', '', '', '9. Các loại thuế khác', '9.Others', '/3338', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5987, 'DNL', '98', 'NS', '', '', '', '', '', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5988, 'DNL', '98', 'NS*', '', '', '', '', 'II - Các khoản phải nộp khác', 'III - OTHER PAYMENTS', '/3339', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5989, 'DNL', '98', 'NS', '', '', '', '', '1. Các khoản phụ thu                       (33391)', '1.Extra collections', '/33391', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5990, 'DNL', '98', 'NS', '', '', '', '', '2. Các khoản phí ,lệ phí                   (33392)', '2.Fees and charges', '/33392', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5991, 'DNL', '98', 'NS', '', '', '', '', '3. Các khoản phải nộp khác            (33393)', '3.Others', '/33393', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5992, 'DNL', '04', 'CB*', '01', '', '', '', 'Tài sản lưu động', 'Current assers', '1-129-139-154-159,3', '46098887435.00', '24403939345.00', '0.00', '0.00', '0.00'),
(5993, 'DNL', '04', 'CB', '', '', '', '', ' - Vốn bằng tiền', ' - Capital in cash', '11', '806071972.00', '322448721.00', '0.00', '0.00', '0.00'),
(5994, 'DNL', '04', 'CB', '', '', '', '', ' - Đầu tư tài chính ngắn hạn', ' - Long-term investments', '12-129', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5995, 'DNL', '04', 'CB', '', '', '', '', ' - Các khoản nợ phải thu', ' - Accounts Receivable', '13-1381-139,3', '43019685085.00', '23815230505.00', '0.00', '0.00', '0.00'),
(5996, 'DNL', '04', 'CB', '', '', '', '', '    + Các khoản nợ khó đòi', '    + Doubtful debt', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(5997, 'DNL', '04', 'CB', '', '', '', '', ' - Hàng tồn kho', ' - Inventories', '15-154-159', '38648175.00', '39011075.00', '0.00', '0.00', '0.00'),
(5998, 'DNL', '04', 'CB', '', '', '', '', ' - Tài sản lưu động khác', ' - Orther current assets', '14,16', '2234482203.00', '227249044.00', '0.00', '0.00', '0.00'),
(5999, 'DNL', '04', 'CB*', '02', '', '', '', 'Tài sản cố định', 'Fixed assets', '2-214-229', '1126755120.00', '1269549327.00', '0.00', '0.00', '0.00'),
(6000, 'DNL', '04', 'CB', '', '', '', '', ' - Nguyên giá tài sản cố định', ' - Cost', '21', '2602579084.00', '2481518466.00', '0.00', '0.00', '0.00'),
(6001, 'DNL', '04', 'CB', '', '', '', '', ' - Giá trị hao mòn lũy kế', ' - Accumulated Depreciation', '214', '-1780567212.00', '-1516712387.00', '0.00', '0.00', '0.00'),
(6002, 'DNL', '04', 'CB', '', '', '', '', ' - Đầu tư tài chính dài hạn', ' - Long-term investments', '22-229', '10000000.00', '10000000.00', '0.00', '0.00', '0.00'),
(6003, 'DNL', '04', 'CB', '', '', '', '', ' - Chi phí XDCB dở dang', ' - Construction in progress', '241', '294743248.00', '294743248.00', '0.00', '0.00', '0.00'),
(6004, 'DNL', '04', 'CB', '', '', '', '', ' - Các khoản ký quỹ ,ký cược dài hạn', ' - Long-term deposits', '244', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6005, 'DNL', '04', 'CB*', '03', '', '', '', 'Nợ ngắn hạn', 'Short-term liabilities', '31,33-3381-335,13-139', '47447766387.00', '25315631247.00', '0.00', '0.00', '0.00'),
(6006, 'DNL', '04', 'CB', '', '', '', '', ' - Vay ngắn hạn quá hạn trả', ' - Short-term borrowings of which overdue', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6007, 'DNL', '04', 'CB*', '04', '', '', '', 'Nợ dài hạn', 'Long-term Liabilities', '34-344', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6008, 'DNL', '04', 'CB', '', '', '', '', ' - Vay dài hạn quá hạn trả', ' - Long-term borrowings of which overdue', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6009, 'DNL', '04', 'CB*', '05', '', '', '', 'Vốn kinh doanh', 'Paid in capital', '4111,4112,441', '3377828142.00', '3377828142.00', '0.00', '0.00', '0.00'),
(6010, 'DNL', '04', 'CB', '', '', '', '', ' - Vốn cố định       ( 41111 ,41121 )', ' - Fixed assets       ( 41111 ,41121 )', '41111,41121', '2572258123.00', '2572258123.00', '0.00', '0.00', '0.00'),
(6011, 'DNL', '04', 'CB', '', '', '', '', ' - Vốn lưu động     ( 41112 ,41122 )', ' - Current assets    ( 41112 ,41122 )', '41112,41122', '757269371.00', '757269371.00', '0.00', '0.00', '0.00'),
(6012, 'DNL', '04', 'CB', '', '', '', '', ' - Vốn xây dựng cơ bản', ' - Funds for capital expenditures', '441', '48300648.00', '48300648.00', '0.00', '0.00', '0.00'),
(6013, 'DNL', '04', 'CB*', '06', '', '', '', 'Các quỹ', 'Funds', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6014, 'DNL', '04', 'CB*', '', '', '', '', ' - Quỹ phát triển kinh doanh', ' - Business development funds', 'CK4141', '195602574.00', '195602574.00', '0.00', '0.00', '0.00'),
(6015, 'DNL', '04', 'CB', '', '', '', '', '   + Số dư đầu năm', '   + Opening', 'DK4141', '195602574.00', '195602574.00', '0.00', '0.00', '0.00'),
(6016, 'DNL', '04', 'CB', '', '', '', '', '   + Đã trích trong năm', '   + Increase', 'CO4141', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6017, 'DNL', '04', 'CB', '', '', '', '', '   + Thực chi trong năm', '   + Decrease', 'NO4141', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6018, 'DNL', '04', 'CB*', '', '', '', '', ' - Quỹ dự trữ tài chính', ' - Reserved funds', 'CK415', '50479823.00', '50479823.00', '0.00', '0.00', '0.00'),
(6019, 'DNL', '04', 'CB', '', '', '', '', '   + Số dư đầu năm', '   + Opening', 'DK415', '50479823.00', '50479823.00', '0.00', '0.00', '0.00'),
(6020, 'DNL', '04', 'CB', '', '', '', '', '   + Đã trích trong năm', '   + Increase', 'CO415', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6021, 'DNL', '04', 'CB', '', '', '', '', '   + Thực chi trong năm', '   + Decrease', 'NO415', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6022, 'DNL', '04', 'CB*', '', '', '', '', ' - Quỹ khen thưởng ,phúc lợi', ' - Bonus & welfare funds', 'CK431', '1265151.00', '1065151.00', '0.00', '0.00', '0.00'),
(6023, 'DNL', '04', 'CB', '', '', '', '', '   + Số dư đầu năm', '   + Opening', 'DK431', '23034751.00', '23034751.00', '0.00', '0.00', '0.00'),
(6024, 'DNL', '04', 'CB', '', '', '', '', '   + Đã trích trong năm', '   + Increase', 'CO431', '0.00', '5243849.00', '0.00', '0.00', '0.00'),
(6025, 'DNL', '04', 'CB', '', '', '', '', '   + Thực chi trong năm', '   + Decrease', 'NO431', '21769600.00', '27213449.00', '0.00', '0.00', '0.00'),
(6026, 'DNL', '04', 'CB*', '', '', '', '', ' - Quỹ trợ cấp mất việc làm', ' - Workless allowances funds', 'CK416', '25401330.00', '0.00', '0.00', '0.00', '0.00'),
(6027, 'DNL', '04', 'CB', '', '', '', '', '   + Số dư đầu năm', '   + Opening', 'DK416', '25401330.00', '25401330.00', '0.00', '0.00', '0.00'),
(6028, 'DNL', '04', 'CB', '', '', '', '', '   + Đã trích trong năm', '   + Increase', 'CO416', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6029, 'DNL', '04', 'CB', '', '', '', '', '   + Thực chi trong năm', '   + Decrease', 'NO416', '0.00', '25401330.00', '0.00', '0.00', '0.00'),
(6030, 'DNL', '04', 'CB*', '08', '', '', '', 'Kết quả kinh doanh', 'Income summary', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6031, 'DNL', '04', 'CB', '', '', '', '', ' - Sản lượng sản phẩm chủ yếu', ' - Quantity of main Products', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6032, 'DNL', '04', 'CB', '', '', '', '', ' - Tổng doanh thu', ' - Gross tunover', 'DT911', '5152041080.00', '38674630364.00', '0.00', '0.00', '0.00'),
(6033, 'DNL', '04', 'CB', '', '', '', '', ' - Tổng chi phí', ' - Total costs', 'CP911', '5044490680.00', '38813601537.00', '0.00', '0.00', '0.00'),
(6034, 'DNL', '04', 'CB', '', '', '', '', ' - Tổng lãi ,lổ', ' - Total profits,loss', 'LAI421', '107550400.00', '-138971173.00', '0.00', '0.00', '0.00'),
(6035, 'DNL', '04', 'CB*', '09', '', '', '', 'Nộp ngân sách nhà nước', 'Payable to state budget', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6036, 'DNL', '04', 'CB', '', '', '', '', ' - Tổng số thuế phải nộp trong năm', ' - Total taxes payable in year', 'CO333', '913181414.00', '2326041442.00', '0.00', '0.00', '0.00'),
(6037, 'DNL', '04', 'CB', '', '', '', '', '    + Thuế lợi tức', '    + Profits tax', 'CO3334', '105022360.00', '105022360.00', '0.00', '0.00', '0.00'),
(6038, 'DNL', '04', 'CB', '', '', '', '', ' - Tổng số thuế đã nộp', ' - Total paid taxes', 'NO333', '431339098.00', '2094942413.00', '0.00', '0.00', '0.00'),
(6039, 'DNL', '04', 'CB', '', '', '', '', '    + Thuế lợi tức', '    + Profits tax', 'NO3334', '77939178.00', '77939178.00', '0.00', '0.00', '0.00'),
(6040, 'DNL', '04', 'CB*', '10', '', '', '', 'Lao động', 'Labour', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6041, 'DNL', '04', 'CB', '', '', '', '', ' - Hợp đồng ngắn hạn', ' - Short-term contract', '', '550.00', '550.00', '0.00', '0.00', '0.00'),
(6042, 'DNL', '04', 'CB', '', '', '', '', ' - Hợp đồng dài hạn', ' - Long-term contract', '', '55.00', '55.00', '0.00', '0.00', '0.00'),
(6043, 'DNL', '04', 'CB*', '11', '', '', '', 'Thu nhập', 'Income', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6044, 'DNL', '04', 'CB', '', '', '', '', ' - Tổng quỹ lương', ' - Toatal salaries', 'CO-334', '1117166944.00', '6536522377.00', '0.00', '0.00', '0.00'),
(6045, 'DNL', '04', 'CB', '', '', '', '', ' - Thu nhập khác', ' - Other income', 'NO-431', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6046, 'DNL', '04', 'CB', '', '', '', '', '   + Tiền lương bình quân', '   + Average salaries', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6047, 'DNL', '04', 'CB', '', '', '', '', '   + Thu nhập bình quân', '   + Average income', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6048, 'DNL', '', '---', '--', '', '', '', '--------------------------------------------------', '--------------------------------------------------', '-------------------------', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6049, 'DNL', '99', 'KQ*', '01', '', '', '', ' - Tổng doanh thu', ' - Gross turnover', '51/52,53,333,91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6050, 'DNL', '99', 'KQ', '02', '', '', '', '   Trong đó : doanh thu hàng xuất khẩu     (51119)', '   of which : turnover of export', '/51119', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6051, 'DNL', '99', 'KQ*', '03', '', '', '', ' - Các khoản giãm trừ ( 05+06+07 )', ' - Deductions (04+05+06+07)', 'Z(05+06+07)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6052, 'DNL', '99', 'KQ', '05', '', '', '', '   + Giãm giá hàng bán', '   + Devaluation', '51/532', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6053, 'DNL', '99', 'KQ', '06', '', '', '', '   + Hàng bán bị trả lại', '   + Sold goods to be returned', '51/531', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6054, 'DNL', '99', 'KQ', '07', '', '', '', '   + Thuế tiêu thụ đặc biệt , xuất khẩu phải nộp', '   + Payables of turnover and export tax', '51/3331,3332,3333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6055, 'DNL', '99', 'KQ*', '10', '', '', '', '1.Doanh thu thuần ( 01-03 )', '1.Net income (01-03)', 'Z(01-03)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6056, 'DNL', '99', 'KQ*', '11', '', '', '', '2.Giá vốn hàng bán', '2.Original rate of sold goods', '91/632', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6057, 'DNL', '99', 'KQ*', '20', '', '', '', '3.Lợi nhuận gộp ( 10-11)', '3.Gross profit (10-11)', 'Z(10-11)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6058, 'DNL', '99', 'KQ*', '21', '', '', '', '4.Chi phí bán hàng', '4.Sale costs', '91/641', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6059, 'DNL', '99', 'KQ*', '22', '', '', '', '5.Chi phí quản lý doanh nghiệp', '5.Enteprise management costs', '91/642,142', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6060, 'DNL', '99', 'KQ*', '30', '', '', '', '6.Lợi nhuận thuần từ hoạt động kinh doanh  ( 20-21-22)', '6.Net profit from business  ( 20-21-22)', 'Z(20-21-22)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6061, 'DNL', '99', 'KQ', '31', '', '', '', ' - Thu nhập hoạt động tài chính', ' - Income from financial activities', '711/91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6062, 'DNL', '99', 'KQ', '32', '', '', '', ' - Chi phí hoạt động tài chính', ' - Costs for financial activities', '91/811', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6063, 'DNL', '99', 'KQ*', '40', '', '', '', '7.Lợi nhuận hoạt động tài chính ( 31-32 )', '7.Profit from financial activities', 'Z(31-32)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6064, 'DNL', '99', 'KQ', '41', '', '', '', ' - Các khoản thu nhập bất thường', ' - Unforseen income', '721/91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6065, 'DNL', '99', 'KQ', '42', '', '', '', ' - Chi phí bất thường', ' - Unforseen costs', '91/821', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6066, 'DNL', '99', 'KQ*', '50', '', '', '', '8.Lợi nhuận bất thường ( 41-42 )', '8.Unforseen profit (41-42)', 'Z(41-42)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6067, 'DNL', '99', 'KQ*', '60', '', '', '', '9.Tổng lợi nhuận trước thuế ( 30+40+50 )', '9.Gross profit before tax (30+40+50)', 'Z(30+40+50)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6068, 'DNL', '99', 'KQ*', '70', '', '', '', '10.Thuế thu nhập doanh nghiệp phải nộp', '10.Payable profit tax', '421/3334', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6069, 'DNL', '99', 'KQ*', '80', '', '', '', '11.Lợi nhuận sau thuế ( 60 -70 )', '11.Profit after tax (60-70)', 'Z(60-70)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6070, 'DNL', '--', '---', '--', '', '', '', '----------------------------------------', '----------------------------------------', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6071, 'DNL', '99', 'NS*', '10', '', '', '', 'I - Thuế', 'I - Taxes', '/333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6072, 'DNL', '99', 'NS', '11', '', '', '', '1. Thuế giá trị gia tăng hàng bán nội địa', '1.Turnover tax (or VAT)', '/33311', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6073, 'DNL', '99', 'NS', '12', '', '', '', '2. Thuế GTGT hàng nhập khẩu', '2.Turnover tax (or VAT)', '/33312', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6074, 'DNL', '99', 'NS', '13', '', '', '', '3. Thuế tiêu thụ đặc biệt', '3.Excise tax', '/3332', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6075, 'DNL', '99', 'NS', '14', '', '', '', '4. Thuế xuất ,nhập khẩu', '4.Import and export duties', '/3333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6076, 'DNL', '99', 'NS', '15', '', '', '', '5. Thuế thu nhập doanh nghiệp', '5.Profit tax', '/3334', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6077, 'DNL', '99', 'NS', '16', '', '', '', '6. Thu trên vốn', '6.Capital earnings', '/3335', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6078, 'DNL', '99', 'NS', '17', '', '', '', '7. Thuế tài nguyên', '7.Land and house tax', '/3336', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6079, 'DNL', '99', 'NS', '18', '', '', '', '8. Thuế nhà đất', '8.Land lease costs', '/33371', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6080, 'DNL', '99', 'NS', '19', '', '', '', '9. Tiền thuê đất', '9.Land lease costs', '/33372', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6081, 'DNL', '99', 'NS', '20', '', '', '', '10. Các loại thuế khác', '10.Others', '/3338', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6082, 'DNL', '99', 'NS', '', '', '', '', '', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6083, 'DNL', '99', 'NS*', '30', '', '', '', 'II - Các khoản phải nộp khác', 'III - OTHER PAYMENTS', '/3339', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6084, 'DNL', '99', 'NS', '31', '', '', '', '1. Các khoản phụ thu                       (33391)', '1.Extra collections', '/33391', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6085, 'DNL', '99', 'NS', '32', '', '', '', '2. Các khoản phí ,lệ phí                   (33392)', '2.Fees and charges', '/33392', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6086, 'DNL', '99', 'NS', '33', '', '', '', '3. Các khoản phải nộp khác             (33393)', '3.Others', '/33393', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6087, 'DNL', '--', '---', '--', '', '', '', '--------------------------------------------------', '--------------------------------------------------', '-------------------------', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6088, 'DNL', '99', 'GT*', '', '', '', '', 'I - Thuế giá trị gia tăng được khấu trừ', 'I - Thuế giá trị gia tăng được khấu trừ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6089, 'DNL', '99', 'GT/', '10', '', '', '', ' 1.Số thuế GTGT còn được khấu trừ ,hoàn lại đầu kỳ', ' 1.Số thuế GTGT còn được khấu trừ ,hoàn lại đầu kỳ', 'DK-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6090, 'DNL', '99', 'GT', '11', '', '', '', ' 2.Số thuế GTGT được khấu trừ phát sinh', ' 2.Số thuế GTGT được khấu trừ phát sinh', 'NO-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6091, 'DNL', '99', 'GT', '12', '', '', '', ' 3.Số thuế GTGT đã được khấu trừ ,đã hoàn lại ,thuế GTGT', ' 3.Số thuế GTGT đã được khấu trừ ,đã hoàn lại ,thuế GTGT', 'CO-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6092, 'DNL', '99', 'GT', '', '', '', '', '    hàng mua trả lại và không được khấu trừ  ( 12 = 13 + 14 +15 )', '    hàng mua trả lại và không được khấu trừ  ( 12 = 13 + 14 +15 )', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6093, 'DNL', '99', 'GT', '', '', '', '', '    Trong đó :', '    Trong đó :', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6094, 'DNL', '99', 'GT', '13', '', '', '', ' a.Số thuế giá trị gia tăng đã khấu trừ', ' a.Số thuế giá trị gia tăng đã khấu trừ', '3331/133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6095, 'DNL', '99', 'GT', '14', '', '', '', ' b.Số thuế giá trị gia tăng đã hoàn lại', ' b.Số thuế giá trị gia tăng đã hoàn lại', '133/133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6096, 'DNL', '99', 'GT', '15', '', '', '', ' c.Số thuế giá trị gia tăng hàng mua trả lại ,giãm giá hàng mua', ' c.Số thuế giá trị gia tăng hàng mua trả lại ,giãm giá hàng mua', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6097, 'DNL', '99', 'GT', '16', '', '', '', ' d.Số thuế giá trị gia tăng không được khấu trừ', ' c.Số thuế giá trị gia tăng không được khấu trừ', '142/133,632/133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6098, 'DNL', '99', 'GT/', '17', '', '', '', ' 4.Số thuế GTGT còn được khấu trừ ,hoàn lại', ' 4.Số thuế GTGT còn được khấu trừ ,hoàn lại', 'CK-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6099, 'DNL', '99', 'GT', '', '', '', '', '    cuối kỳ  ( 16 = 10+11-12)', '    cuối kỳ  ( 16 = 10+11-12)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6100, 'DNL', '99', 'GT*', '', '', '', '', 'II - Thuế giá trị gia tăng được hoàn lại', 'II - Thuế giá trị gia tăng được hoàn lại', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6101, 'DNL', '99', 'GT/', '20', '', '', '', ' 1. Thuế giá trị gia tăng còn được hoàn lại đầu kỳ', ' 1. Thuế giá trị gia tăng còn được hoàn lại đầu kỳ', 'DK-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6102, 'DNL', '99', 'GT', '21', '', '', '', ' 2. Thuế giá trị gia tăng được hoàn lại phát sinh', ' 2. Thuế giá trị gia tăng được hoàn lại', 'NO-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6103, 'DNL', '99', 'GT', '22', '', '', '', ' 3. Thuế giá trị gia tăng đã hoàn lại', ' 3. Thuế giá trị gia tăng đã hoàn lại', 'CO-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6104, 'DNL', '99', 'GT/', '23', '', '', '', ' 4. Thuế GTGT còn được hoàn lại cuối kỳ cuối kỳ  ( 23 = 20 + 21 - 22)', ' 4. Thuế GTGT còn được hoàn lại cuối kỳ cuối kỳ  ( 23 = 20 + 21 - 22)', 'CK-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6105, 'DNL', '99', 'GT*', '', '', '', '', 'III - Thuế giá trị gia tăng được giảm', 'III - Thuế giá trị gia tăng được miển giãm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6106, 'DNL', '99', 'GT/', '30', '', '', '', ' 1. Thuế giá trị gia tăng còn được giãm đầu kỳ', ' 1. Thuế giá trị gia tăng còn được miển giãm đầu kỳ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6107, 'DNL', '99', 'GT', '31', '', '', '', ' 2. Thuế giá trị gia tăng được giảm phát sinh', ' 2. Thuế giá trị gia tăng được miển giãm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6108, 'DNL', '99', 'GT', '32', '', '', '', ' 3. Thuế giá trị gia tăng đã được giảm', ' 3. Thuế giá trị gia tăng đã được miển giãm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6109, 'DNL', '99', 'GT/', '33', '', '', '', ' 4. Thuế GTGTcòn được giãm cuối kỳ  ( 33 = 30 + 31 - 32)', ' 4. Thuế GTGTcòn được giãm cuối kỳ  ( 33 = 30 + 31 - 32)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6110, 'DNL', '99', 'GT*', '', '', '', '', 'IV - Thuế giá trị gia tăng hàng bán nội địa', 'IV - Thuế giá trị gia tăng hàng bán nội địa', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6111, 'DNL', '99', 'GT/', '40', '', '', '', ' 1.Thuế giá trị gia tăng đầu ra còn phải nộp đầu kỳ', ' 1.Thuế giá trị gia tăng đầu ra còn phải nộp đầu kỳ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6112, 'DNL', '99', 'GT', '41', '', '', '', ' 2.Thuế giá trị gia tăng đầu ra phát sinh', ' 2.Thuế giá trị gia tăng đầu ra phát sinh', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6113, 'DNL', '99', 'GT', '42', '', '', '', ' 3.Thuế giá trị gia tăng đầu vào đã khấu trừ', ' 3.Thuế giá trị gia tăng đầu vào đã khấu trừ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6114, 'DNL', '99', 'GT', '43', '', '', '', ' 4.Thuế giá trị gia tăng hàng bán bị trả lại ,bị giảm giá', ' 4.Thuế giá trị gia tăng hàng bán bị trả lại ,bị giảm giá', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6115, 'DNL', '99', 'GT', '44', '', '', '', ' 5.Thuế giá trị gia tăng được giảm trừ vào số thuế phải nộp', ' 5.Thuế giá trị gia tăng được giảm trừ vào số thuế phải nộp', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6116, 'DNL', '99', 'GT', '45', '', '', '', ' 6.Thuế giá trị gia tăng hàng bán nội địa đã nộp vào NSNN', ' 6.Thuế giá trị gia tăng hàng bán nội địa đã nộp vào NSNN', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6117, 'DNL', '99', 'GT/', '46', '', '', '', ' 7.Thuế giá trị gia tăng hàng bán nội địa còn phải nộp cuối kỳ', ' 7.Thuế giá trị gia tăng hàng bán nội địa còn phải nộp cuối kỳ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6118, 'DNL', '99', 'GT', '', '', '', '', '     ( 46 = 40+41-42-43-44-45 )', '     ( 46 = 40+41-42-43-44-45 )', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6119, 'DNL', '==', '===', '==', '', '', '', '======================================================================', '======================================================================', '=========================', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6120, 'DNL', '', 'GT1', 'A', '10', '', '', 'Không phát sinh hoạt động mua, bán trong kỳ (đánh dấu &quot;X&quot;)', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6121, 'DNL', '', 'GT1', 'B', '', '11', '', 'Thuế GTGT còn được khấu trừ kỳ trước chuyển sang', 'Sales of merchandise & service', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6122, 'DNL', '', 'GT1', 'C', '', '', '', 'Kê khai thuế GTGT phải nộp Ngân sách nhà nước', 'VAT of merchandise & service', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6123, 'DNL', '', 'GT1', 'I', '', '', '', 'Hàng hoá, dịch vụ (HHDV) mua vào', ' a -  0%', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6124, 'DNL', '', 'GT1', '1', '12', '13', 'Z', 'Hàng hoá, dịch vụ mua vào trong kỳ ( [12]=[14]+[16]; [13]=[15]+[17] )', ' b -  5%', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6125, 'DNL', '', 'GT1', 'a', '14', '15', '', '        - Hàng hoá, dịch vụ mua vào trong nước', ' c -  10%', '', '6433395191.00', '412195404.00', '0.00', '0.00', '0.00'),
(6126, 'DNL', '', 'GT1', 'b', '16', '17', '', '        - Hàng hoá, dịch vụ nhập khẩu', ' d -  20%', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6127, 'DNL', '', 'GT1', '2', '', '', '', 'Điều chỉnh thuế GTGT của HHDV mua vào các kỳ trước', 'Purchase of merchandise & service', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6128, 'DNL', '', 'GT1', 'a', '18', '19', '', '        - Điều chỉnh tăng', 'VAT Purchase of merchandise & service', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6129, 'DNL', '', 'GT1', 'b', '20', '21', '', '        - Điều chỉnh giảm', 'VAT Deductions', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6130, 'DNL', '', 'GT1', '3', '', '22', 'Z', 'Tổng số thuế GTGT của HHDV mua vào ( [22] = [13] + [19] - [21] )', 'Payables of VAT  (+) or returned (-) in period', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6131, 'DNL', '', 'GT1', '4', '', '23', 'Z', 'Tổng số thuế GTGT được khấu trừ kỳ này', 'Outstanding prior period of VAT', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6132, 'DNL', '', 'GT1', 'II', '', '', '', 'Hàng hóa ,dịch vụ bán ra', ' a - Short', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6133, 'DNL', '', 'GT1', '1', '24', '25', 'Z', 'Hàng hoá, dịch vụ bán ra trong kỳ ( [24]=[26]+[27] ; [25]=[28] )', ' b - Over', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6134, 'DNL', '', 'GT1', '11', '26', '', '', 'Hàng hóa ,dịch vụ bán ra không chịu thuế GTGT', 'Paid of VAT in month', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6135, 'DNL', '', 'GT1', '12', '', '', '', 'Hàng hóa ,dịch vụ bán ra chịu thuế GTGT', '  Include other Local', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6136, 'DNL', '', 'GT1', '', '27', '28', 'Z', '    ( [27] = [29]+[30]+[32] ; [28] =[31]+[33] )', 'Returned of VAT in month', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6137, 'DNL', '', 'GT1', 'a', '29', '', '', '        - Hàng hóa ,dịch vụ bán ra chịu thuế suất 0%', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6138, 'DNL', '', 'GT1', 'b', '30', '31', '', '        - Hàng hóa ,dịch vụ bán ra chịu thuế suất 5%', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6139, 'DNL', '', 'GT1', 'c', '32', '33', '', '        - Hàng hóa ,dịch vụ bán ra chịu thuế suất 10%', '', '', '1974906300.00', '406588320.00', '0.00', '0.00', '0.00'),
(6140, 'DNL', '', 'GT1', '2', '', '', '', 'Điều chỉnh thuế GTGT của HHDV bán ra các kỳ trước', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6141, 'DNL', '', 'GT1', 'a', '34', '35', '', '        - Điều chỉnh tăng', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6142, 'DNL', '', 'GT1', 'b', '36', '37', '', '        - Điều chỉnh giảm', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6143, 'DNL', '', 'GT1', '3', '', '', '', 'Tổng doanh thu và thuế GTGT của DVHH bán ra', 'Payables of VAT in this month', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6144, 'DNL', '', 'GT1', '', '38', '39', 'Z', '    ( [38] = [24]+[34]-[36] ; [39] =[25]+[35]-[37] )', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6145, 'DNL', '', 'GT1', 'II', '', '', '', 'Xác định nghĩa vụ thuế GTGT phải nộp trong kỳ :', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6146, 'DNL', '', 'GT1', '1', '', '40', 'Z', 'Thuế GTGT phải nộp trong kỳ ( [40] = [39] - [23] - [11] )', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6147, 'DNL', '', 'GT1', '2', '', '41', 'Z', 'Thuế GTGT chưa khấu trừ hết kỳ này  ( [41] = [39] - [23] - [11] )', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6148, 'DNL', '', 'GT1', '21', '', '42', '', 'Thuế GTGT đề nghị hoàn kỳ này', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6149, 'DNL', '', 'GT1', '22', '', '43', 'Z', 'Thuế GTGT còn được khấu trừ chuyển sang kỳ sau  ( [43] = [41] - [42] )', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6150, 'DNL', '==', '===', '==', '', '', '', '======================================================================', '======================================================================', '=========================', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6151, 'DNL', '1', 'GT2', ' 1', '', '', '', 'Hàng hóa ,dịch vụ bán ra', 'Sales of merchandise & service', '', '7024523122.00', '462930311.00', '0.00', '0.00', '0.00'),
(6152, 'DNL', '1a', 'GT2', ' 2', '', '', '', 'Hàng hóa ,dịch vụ không chịu thuế GTGT', 'Not VAT of merchandise & service', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6153, 'DNL', '2', 'GT2', ' 3', '', '', '', 'Hàng hóa ,dịch vụ chịu thế GTGT', 'VAT of merchandise & service', '', '7011393177.00', '345322578.00', '0.00', '0.00', '0.00'),
(6154, 'DNL', '2a', 'GT2', '', '', '', '', ' a - Hàng hóa xuất khẩu thuế suất 0%', ' a -  0%', '', '165172796.00', '0.00', '0.00', '0.00', '0.00'),
(6155, 'DNL', '2b', 'GT2', '', '', '', '', ' b - Hàng hóa ,dịch vụ thuế suất 5%', ' b -  5%', '', '6785989133.00', '339299453.00', '0.00', '0.00', '0.00'),
(6156, 'DNL', '2c', 'GT2', '', '', '', '', ' c - Hàng hóa ,dịch vụ thuế suất 10%', ' c -  10%', '', '60231248.00', '6023125.00', '0.00', '0.00', '0.00'),
(6157, 'DNL', '2d', 'GT2', '', '', '', '', ' d - Hàng hóa ,dịch vụ thuế suất 20%', ' d -  20%', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6158, 'DNL', '3', 'GT2', ' 4', '', '', '', 'Hàng hóa ,vật tư ,dịch vụ TSCĐ mua vào hoặc nhập khẩu', 'Purchase of merchandise & service', '', '16529033475.00', '1077729243.00', '0.00', '0.00', '0.00'),
(6159, 'DNL', '3', 'GT2', ' 5', '', '', '', 'Hàng hóa dịch vụ dùng cho SXKD hàng hóa ,dịch vụ', 'Merchandise & service for Work', '', '16529033475.00', '1077729243.00', '0.00', '0.00', '0.00'),
(6160, 'DNL', '', 'GT2', '', '', '', '', 'chịu thuế GTGT được tính khấu trừ thuế', 'deducted VAT', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6161, 'DNL', '7', 'GT2', ' 6', '', '', '', 'Thuế GTGT kỳ trước chuyển sang', 'Outstanding prior period of VAT', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6162, 'DNL', '7a', 'GT2', '', '', '', '', ' a - Nộp thiếu', ' a - Short', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6163, 'DNL', '7b', 'GT2', '', '', '', '', ' b - Nộp thừa hoặc chưa được khấu trừ', ' b - Over', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6164, 'DNL', '6', 'GT2', ' 7', '', '', '', 'Thuế GTGT phải nộp năm quyết toán', 'Payables of VAT in Year', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6165, 'DNL', '8', 'GT2', ' 8', '', '', '', 'Thuế GTGT đã nộp từng năm', 'Paid of VAT in Year', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6166, 'DNL', '', 'GT2', '', '', '', '', '     Trong đó :  Nộp tại các tỉnh ,thành khác', '  Include other Local', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6167, 'DNL', '9', 'GT2', ' 9', '', '', '', 'Thuế GTGT đã được hoàn trả trong năm', 'Returned of VAT in Year', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6168, 'DNL', '10', 'GT2', '10', '', '', '', 'Thuế GTGT cuối kỳ quyết toán', 'VAT closing', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6169, 'DNL', '11', 'GT2', '', '', '', '', ' + Nộp thiếu', ' a - Short', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6170, 'DNL', '12', 'GT2', '', '', '', '', ' + Nộp thừa hoặc chưa được khấu trừ', ' b - Over', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6171, 'DNL', '==', '===', '==', '', '', '', '======================================================================', '======================================================================', '=========================', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6172, 'DNL', '', 'TN1', ' 1', '', '', '', 'Doanh thu tính thuế', 'Doanh thu tính thuế', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6173, 'DNL', '', 'TN1', ' 2', '', '', '', 'Tỷ lệ thu nhập chịu thuế tính trên doanh thu  (%)', 'Tỷ lệ thu nhập chịu thuế tính trên doanh thu  (%)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6174, 'DNL', '', 'TN1', ' 3', '', '', '', 'Thu nhập chịu thuế', 'Thu nhập chịu thuế', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6175, 'DNL', '', 'TN1', ' 4', '', '', '', 'Thuế suất thuế thu nhập doanh nghiệp (%)', 'Thuế suất thuế thu nhập doanh nghiệp (%)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6176, 'DNL', '', 'TN1', ' 5', '', '', '', 'Số thuế thu nhập doanh nghiệp phải nộp', 'Số thuế thu nhập doanh nghiệp phải nộp', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6177, 'DNL', '==', '===', '==', '', '', '', '======================================================================', '======================================================================', '=========================', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6178, 'DNL', '*', 'TN2', '', '', '', '', '1. Doanh thu', '1. Doanh thu', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6179, 'DNL', '', 'TN2', '', '', '', '', ' a - Doanh thu bán hàng', ' a - Doanh thu bán hàng', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6180, 'DNL', '', 'TN2', '', '', '', '', ' b - Doanh thu bán thành phẩm', ' b - Doanh thu bán thành phẩm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6181, 'DNL', '', 'TN2', '', '', '', '', ' c - Doanh thu cung cấp dịch vụ', ' c - Doanh thu cung cấp dịch vụ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6182, 'DNL', '*', 'TN2', '', '', '', '', '2. Các khoản giãm trừ', '2. Các khoản giãm trừ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6183, 'DNL', '', 'TN2', '', '', '', '', ' a - Chiết khấu bán hàng', ' a - Chiết khấu bán hàng', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6184, 'DNL', '', 'TN2', '', '', '', '', '    - Chiết khấu hàng hóa', '    - Chiết khấu hàng hóa', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6185, 'DNL', '', 'TN2', '', '', '', '', '    - Chiết khấu thành phẩm', '    - Chiết khấu thành phẩm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6186, 'DNL', '', 'TN2', '', '', '', '', '    - Chiết khấu dịch vụ', '    - Chiết khấu dịch vụ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6187, 'DNL', '', 'TN2', '', '', '', '', ' b - Giãm giá bán hàng', ' b - Giãm giá bán hàng', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6188, 'DNL', '', 'TN2', '', '', '', '', ' c - Hàng bán bị trả lại', ' c - Hàng bán bị trả lại', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6189, 'DNL', '*', 'TN2', '', '', '', '', '3. Chi phí sản xuất kinh doanh hợp lý', '3. Chi phí sản xuất kinh doanh hợp lý', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6190, 'DNL', '', 'TN2', '', '', '', '', ' - Khấu hao Tài sản cố định', ' - Khấu hao Tài sản cố định', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6191, 'DNL', '', 'TN2', '', '', '', '', ' - Nguyên vật liệu', ' - Nguyên vật liệu', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6192, 'DNL', '', 'TN2', '', '', '', '', ' - Tiền lương', ' - Tiền lương', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6193, 'DNL', '', 'TN2', '', '', '', '', ' - Chi phí khác', ' - Chi phí khác', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6194, 'DNL', '', 'TN2', '', '', '', '', '   Trong đó :', '   Trong đó :', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6195, 'DNL', '', 'TN2', '', '', '', '', '  + Lãi tiền vay', '  + Lãi tiền vay', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6196, 'DNL', '', 'TN2', '', '', '', '', '  + Trích các khoản dự phòng', '  + Trích các khoản dự phòng', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6197, 'DNL', '', 'TN2', '', '', '', '', '  + Chi phí quảng cáo', '  + Chi phí quảng cáo', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6198, 'DNL', '', 'TN2', '', '', '', '', '  + Chi phí khác', '  + Chi phí khác', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6199, 'DNL', '*', 'TN2', '', '', '', '', '4. Tổng thu nhập từ SX ,KD (1-2-3)', '4. Tổng thu nhập từ SX ,KD (1-2-3)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6200, 'DNL', '*', 'TN2', '', '', '', '', '5. Thu nhập khác', '5. Thu nhập khác', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6201, 'DNL', '', 'TN2', '', '', '', '', ' - Chênh lệnh mua bán chứng khoán', ' - Chênh lệnh mua bán chứng khoán', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6202, 'DNL', '', 'TN2', '', '', '', '', ' - Thu nhập từ quyền sở hữu ,quyền sử dụng tài sản', ' - Thu nhập từ quyền sở hữu ,quyền sử dụng tài sản', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6203, 'DNL', '', 'TN2', '', '', '', '', ' - Thu nhập từ chuyển nhượng ,thanh lý tài sản', ' - Thu nhập từ chuyển nhượng ,thanh lý tài sản', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6204, 'DNL', '', 'TN2', '', '', '', '', ' - Lãi tiền gửi ,lãi cho vay vốn ,lãi bán hàng trả chậm', ' - Lãi tiền gửi ,lãi cho vay vốn ,lãi bán hàng trả chậm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6205, 'DNL', '', 'TN2', '', '', '', '', ' - Chênh lệch do bán ngoại tệ', ' - Chênh lệch do bán ngoại tệ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6206, 'DNL', '', 'TN2', '', '', '', '', ' - Kết dư các khoản trích trước chi không hết ,các khoản dự phòng', ' - Kết dư các khoản trích trước chi không hết ,các khoản dự phòng', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6207, 'DNL', '', 'TN2', '', '', '', '', ' - Thu về tiền phạt vi phạm hợp đồng kinh tế', ' - Thu về tiền phạt vi phạm hợp đồng kinh tế', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6208, 'DNL', '', 'TN2', '', '', '', '', ' - Thu các khoản thu khó đòi nay đòi được', ' - Thu các khoản thu khó đòi nay đòi được', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6209, 'DNL', '', 'TN2', '', '', '', '', ' - Thu các khoản nợ phải trả không còn chủ', ' - Thu các khoản nợ phải trả không còn chủ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6210, 'DNL', '', 'TN2', '', '', '', '', ' - Các khoản thu nhập bỏ sót từ những năm trước', ' - Các khoản thu nhập bỏ sót từ những năm trước', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6211, 'DNL', '', 'TN2', '', '', '', '', ' - Các khoản thu nhập nhận được từ nước ngoài', ' - Các khoản thu nhập nhận được từ nước ngoài', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6212, 'DNL', '', 'TN2', '', '', '', '', ' - Các khoản thu nhập không tính vào doanh thu', ' - Các khoản thu nhập không tính vào doanh thu', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6213, 'DNL', '', 'TN2', '', '', '', '', ' - Các khoản thu nhập khác', ' - Các khoản thu nhập khác', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6214, 'DNL', '*', 'TN2', '', '', '', '', '6. Lỗ năm trước chuyển sang', '6. Lỗ năm trước chuyển sang', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6215, 'DNL', '*', 'TN2', '', '', '', '', '7. Tổng thu nhập chịu thuế (4+5+6)', '7. Tổng thu nhập chịu thuế (4+5+6)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6216, 'DNL', '*', 'TN2', '', '', '', '', '8. Thu nhập chịu thuế thu nhập bổ sung', '8. Thu nhập chịu thuế thu nhập bổ sung', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6217, 'DNL', '', 'TN2', '', '', '', '', '  Trong đó :', '  Trong đó :', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6218, 'DNL', '', 'TN2', '', '', '', '', '   Thu nhập từ góp vốn cổ phần ,liên doanh ,liên kết kinh tế', '   Thu nhập từ góp vốn cổ phần ,liên doanh ,liên kết kinh tế', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6219, 'DNL', '==', '===', '==', '', '', '', '======================================================================', '======================================================================', '=========================', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6220, 'DNL', '', 'TN3', '', '', '', '', '1. Tổng doanh thu tính thu nhập chịu thuế', '1. Tổng doanh thu tính thu nhập chịu thuế', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6221, 'DNL', '', 'TN3', '', '', '', '', '2. Chi phí sản xuất kinh doanh hợp lý', '2. Chi phí sản xuất kinh doanh hợp lý', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6222, 'DNL', '', 'TN3', '', '', '', '', '3. Thu nhập từ hoạt động sản xuất kinh doanh (1-2)', '3. Thu nhập từ hoạt động sản xuất kinh doanh (1-2)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6223, 'DNL', '', 'TN3', '', '', '', '', '4. Thu nhập khác', '4. Thu nhập khác', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6224, 'DNL', '', 'TN3', '', '', '', '', '5. Lỗ năm trước chuyển sang', '5. Lỗ năm trước chuyển sang', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6225, 'DNL', '', 'TN3', '', '', '', '', '6. Tổng thu nhập chịu thuế (3+4-5)', '6. Tổng thu nhập chịu thuế (3+4-5)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6226, 'DNL', '', 'TN3', '', '', '', '', '7. Thuế suất', '7. Thuế suất', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6227, 'DNL', '', 'TN3', '', '', '', '', '8. Thuế thu nhập (6x7)', '8. Thuế thu nhập (6x7)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6228, 'DNL', '', 'TN3', '', '', '', '', '9. Thu nhập tính thuế bổ sung', '9. Thu nhập tính thuế bổ sung', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6229, 'DNL', '', 'TN3', '', '', '', '', '10. Thuế suất bổ sung', '10. Thuế suất bổ sung', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6230, 'DNL', '', 'TN3', '', '', '', '', '11. Thuế thu nhập bổ sung', '11. Thuế thu nhập bổ sung', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6231, 'DNL', '', 'TN3', '', '', '', '', '12. Tổng thuế thu nhập phải nộp (8+11)', '12. Tổng thuế thu nhập phải nộp (8+11)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6232, 'DNL', '', 'TN3', '', '', '', '', '13. Thanh toán thuế', '13. Thanh toán thuế', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6233, 'DNL', '', 'TN3', '', '', '', '', ' - Năm trước chuyển sang [ Nộp thiếu (+) ,nộp thừa (-) ]', ' - Năm trước chuyển sang [ Nộp thiếu (+) ,nộp thừa (-) ]', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6234, 'DNL', '', 'TN3', '', '', '', '', ' - Phải nộp năm nay', ' - Phải nộp năm nay', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6235, 'DNL', '', 'TN3', '', '', '', '', ' - Đã tạm nộp trong năm', ' - Đã tạm nộp trong năm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6236, 'DNL', '', 'TN3', '', '', '', '', ' - Trừ thuế đã nộp ở nước ngoài', ' - Trừ thuế đã nộp ở nước ngoài', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6237, 'DNL', '', 'TN3', '', '', '', '', ' - Số còn phải nộp', ' - Số còn phải nộp', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6238, 'DNL', '==', '===', '==', '', '', '', '======================================================================', '======================================================================', '=========================', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6239, 'DNL', '', 'TN4', '', '', '', '', ' 1.Vốn cố định', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6240, 'DNL', '', 'TN4', '', '', '', '', '    a. Vốn cố định tính thu', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6241, 'DNL', '', 'TN4', '', '', '', '', ' 2.Vốn lưu động', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6242, 'DNL', '', 'TN4', '', '', '', '', '    a. Vốn lưu động tính thu', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6243, 'DNL', '', 'TN4', '', '', '', '', ' 3.Vốn tăng giãm trong kỳ', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6244, 'DNL', '', 'TN4', '', '', '', '', '    Trong đó : Vốn ngân sách', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6245, 'DNL', '', 'TN4', '', '', '', '', '    a. Vốn cố định tăng (+) giãm (-)', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6246, 'DNL', '', 'TN4', '', '', '', '', '    b. Vốn lưu động tăng (+) giãm (-)', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6247, 'DNL', '', 'TN4', '', '', '', '', ' 4.Tính thu sử dụng vốn cuối kỳ ( 1a+2a+3a+3b)', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6248, 'DNL', '', 'TN4', '', '', '', '', ' 5.Góp vốn liên doanh', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6249, 'DNL', '', 'TN4', '', '', '', '', '    a. Góp vốn giá trị Quyền sử dụng đất', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6250, 'DNL', '', 'TN4', '', '', '', '', ' 6.Tổng số vốn phải thu tính sử dụng vốn ( 4+5-5a)', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6251, 'DNL', '', 'TN4', '', '', '', '', ' 7.Tỉ lệ thu trên vốn  x  mức vốn tính thu', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6252, 'DNL', '', 'TN4', '', '', '', '', '    a. Tỉ lệ  ... x', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6253, 'DNL', '', 'TN4', '', '', '', '', '    b. Tỉ lệ  ... x', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6254, 'DNL', '', 'TN4', '', '', '', '', ' 8.Quan hệ nộp NS về sử dụng vốn', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6255, 'DNL', '', 'TN4', '', '', '', '', '    a. Số kỳ trước chuyển sang', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6256, 'DNL', '', 'TN4', '', '', '', '', '         + Trong đó thu SDV liên doanh', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6257, 'DNL', '', 'TN4', '', '', '', '', '    b. Số phát sinh phân bổ trong năm', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6258, 'DNL', '', 'TN4', '', '', '', '', '         + Trong đó thu SDV liên doanh', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6259, 'DNL', '', 'TN4', '', '', '', '', ' 9.Tỉ lệ phân bổ ( 4 ---> quý ; 12 --->tháng )', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6260, 'DNL', '', 'TN4', '', '', '', '', ' 10.Tổng số phải thu sử dụng vốn trong kỳ (8b/9)', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6261, 'DNL', '==', '===', '==', '', '', '', '======================================================================', '======================================================================', '=========================', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6262, 'DNL', '02', 'KQ*', '01', '', '', 'VI.25', '1. Doanh thu bán hàng và cung cấp dịch vụ', '1. Gross sales', '511,512/52,53,333,91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6263, 'DNL', '02', 'KQ*', '02', '', '', 'VI.26', '2. Các khoản giảm trừ doanh thu', '2. Less', 'Z( 04+05+06+07)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6264, 'DNL', '02', 'KQ_', '04', '', '', '', '   - Chiết khấu thương mại', ' - Sales discounts', '511,512/521', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6265, 'DNL', '02', 'KQ_', '05', '', '', '', '   - Giảm giá hàng bán', ' - Sales allowances', '511,512/532', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6266, 'DNL', '02', 'KQ_', '06', '', '', '', '   - Hàng bán bị trả lại', ' - Sales returns', '511,512/531', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6267, 'DNL', '02', 'KQ_', '07', '', '', '', '   - Thuế tiêu thụ đặc biệt , thuế xuất khẩu ,Thuế GTGT', ' - Excise tax ,export tax ,VAT tax', '511,512/3331,3332,3333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6268, 'DNL', '02', 'KQ_', '', '', '', '', '      Theo phương pháp trực tiếp phải nộp', '', '', '0.00', '0.00', '0.00', '0.00', '0.00');
INSERT INTO `ketquakd` (`id`, `chedokt`, `kyhieu`, `swt`, `maso`, `kyhieu1`, `kyhieu2`, `tminh`, `chitieu`, `chitieuu`, `cachtinh`, `kytruoc`, `kynay`, `luyke`, `luykeno`, `luykeco`) VALUES
(6269, 'DNL', '02', 'KQ', '10', '', '', '', '3. Doanh thu thuần về bán hàng và cung cấp DV (10 = 01-02)', '3. Net sales ( 10 = 01 - 02 )', 'Z(01-02)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6270, 'DNL', '02', 'KQ', '11', '', '', 'VI.28', '4. Giá vốn hàng bán', '4. Cost of goods sold', '91/632', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6271, 'DNL', '02', 'KQ*', '20', '', '', '', '5. Lợi nhuận gộp về bán hàng và cung cấp DV  ( 20 = 10 -11)', '5. Gross profit ( 20 = 10 -11)', 'Z(10-11)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6272, 'DNL', '02', 'KQ', '21', '', '', 'VI.29', '6. Doanh thu hoạt động tài chính', '6. Income from financial activities', '515/91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6273, 'DNL', '02', 'KQ', '22', '', '', 'VI.30', '7. Chi phí tài chính', '7. Expenses from financial activities', '91/635', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6274, 'DNL', '02', 'KQ', '23', '', '', '', '    Trong đó : Chi phí lãi vay', '    Of witch: Interest payment', '91/6351', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6275, 'DNL', '02', 'KQ', '24', '', '', '', '8. Chi phí bán hàng', '8. Selling expenses', '91/641', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6276, 'DNL', '02', 'KQ', '25', '', '', '', '9. Chi phí quản lý doanh nghiệp', '9. General and administration expenses', '91/642,142', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6277, 'DNL', '02', 'KQ*', '30', '', '', '', '10. Lợi nhuận thuần từ hoạt động kinh doanh', '10. Operating profit', 'Z(20+21-22-24-25)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6278, 'DNL', '02', 'KQ', '', '', '', '', '     [ 30 = 20 + (21-22) - (24+25)  ]', '     [ 30 = 20 + (21-22) - (24+25)  ]', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6279, 'DNL', '02', 'KQ', '31', '', '', '', '11. Thu nhập khác', '11. Other income', '721,711/91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6280, 'DNL', '02', 'KQ', '32', '', '', '', '12. Chi phí khác', '12. Other expenses', '91/811', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6281, 'DNL', '02', 'KQ*', '40', '', '', '', '13. Lợi nhuận khác', '13. Other profit/loss', 'Z(31-32)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6282, 'DNL', '02', 'KQ', '41', '', '', '', '     ( 40 = 31 - 32 )', '     ( 40 = 31 - 32 )', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6283, 'DNL', '02', 'KQ*', '50', '', '', '', '14. Tổng lợi nhuận trước thuế ( 50 = 30 + 40 )', '14. Profit before tax/ loss ( 50 = 30 + 40 )', 'Z(30+40)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6284, 'DNL', '02', 'KQ', '51', '', '', 'VI.31', '15. Chi phí thuế thu nhập doanh nghiệp hiện hành', '15. Current income tax expenses', '91/8211', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6285, 'DNL', '02', 'KQ', '52', '', '', 'VI.32', '16. Chi phí thuế thu nhập doanh nghiệp hoãn lại', '16. Deferred income tax liabilities', '91/8212', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6286, 'DNL', '02', 'KQ*', '60', '', '', '', '17. Lợi nhuận sau thuế thu nhập doanh nghiệp ( 60 = 50 - 51- 52 )', '17. Net profit after tax/ loss ( 60 = 50 - 51- 52 )', 'Z(50-51-52)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6287, 'DNL', '02', 'KQ', '70', '', '', '', '18. Lãi cơ bản trên cổ phiếu (*)', '18. Net profit on stock', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6288, 'DNL', '02', 'NS*', '10', '', '', '', 'I - Thuế', 'I - Taxes', '/333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6289, 'DNL', '02', 'NS', '11', '', '', '', '1. Thuế giá trị gia tăng hàng bán nội địa', '1.Turnover tax (or VAT)', '/33311', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6290, 'DNL', '02', 'NS', '12', '', '', '', '2. Thuế GTGT hàng nhập khẩu', '2.Turnover tax (or VAT)', '/33312', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6291, 'DNL', '02', 'NS', '13', '', '', '', '3. Thuế tiêu thụ đặc biệt', '3.Excise tax', '/3332', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6292, 'DNL', '02', 'NS', '14', '', '', '', '4. Thuế xuất ,nhập khẩu', '4.Import and export duties', '/3333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6293, 'DNL', '02', 'NS', '15', '', '', '', '5. Thuế thu nhập doanh nghiệp', '5.Profit tax', '/3334', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6294, 'DNL', '02', 'NS', '16', '', '', '', '6. Thu trên vốn', '6.Capital earnings', '/3335', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6295, 'DNL', '02', 'NS', '17', '', '', '', '7. Thuế tài nguyên', '7.Land and house tax', '/3336', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6296, 'DNL', '02', 'NS', '18', '', '', '', '8. Thuế nhà đất   (33371)', '8.Land lease costs', '/33371', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6297, 'DNL', '02', 'NS', '19', '', '', '', '9. Tiền thuê đất    (33372)', '9.Land lease costs', '/33372', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6298, 'DNL', '02', 'NS', '20', '', '', '', '10. Các loại thuế khác', '10.Others', '/3338', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6299, 'DNL', '02', 'NS', '', '', '', '', '', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6300, 'DNL', '02', 'NS*', '30', '', '', '', 'II - Các khoản phải nộp khác', 'III - OTHER PAYMENTS', '/3339', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6301, 'DNL', '02', 'NS', '31', '', '', '', '1. Các khoản phụ thu                       (33391)', '1.Extra collections', '/33391', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6302, 'DNL', '02', 'NS', '32', '', '', '', '2. Các khoản phí ,lệ phí                   (33392)', '2.Fees and charges', '/33392', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6303, 'DNL', '02', 'NS', '33', '', '', '', '3. Các khoản phải nộp khác             (33393)', '3.Others', '/33393', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6304, 'DNL', '02', 'GT*', '', '', '', '', 'I - Thuế giá trị gia tăng được khấu trừ', 'I - Thuế giá trị gia tăng được khấu trừ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6305, 'DNL', '02', 'GT/', '10', '', '', '', ' 1.Số thuế GTGT còn được khấu trừ ,hoàn lại đầu kỳ', ' 1.Số thuế GTGT còn được khấu trừ ,hoàn lại đầu kỳ', 'DK-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6306, 'DNL', '02', 'GT', '11', '', '', '', ' 2.Số thuế GTGT được khấu trừ phát sinh', ' 2.Số thuế GTGT được khấu trừ phát sinh', 'NO-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6307, 'DNL', '02', 'GT', '12', '', '', '', ' 3.Số thuế GTGT đã được khấu trừ ,đã hoàn lại ,thuế GTGT', ' 3.Số thuế GTGT đã được khấu trừ ,đã hoàn lại ,thuế GTGT', 'CO-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6308, 'DNL', '02', 'GT', '', '', '', '', '    hàng mua trả lại và không được khấu trừ  ( 12 = 13 + 14 +15 )', '    hàng mua trả lại và không được khấu trừ  ( 12 = 13 + 14 +15 )', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6309, 'DNL', '02', 'GT', '', '', '', '', '    Trong đó :', '    Trong đó :', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6310, 'DNL', '02', 'GT', '13', '', '', '', ' a.Số thuế giá trị gia tăng đã khấu trừ', ' a.Số thuế giá trị gia tăng đã khấu trừ', '3331/133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6311, 'DNL', '02', 'GT', '14', '', '', '', ' b.Số thuế giá trị gia tăng đã hoàn lại', ' b.Số thuế giá trị gia tăng đã hoàn lại', '133/133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6312, 'DNL', '02', 'GT', '15', '', '', '', ' c.Số thuế giá trị gia tăng hàng mua trả lại ,giãm giá hàng mua', ' c.Số thuế giá trị gia tăng hàng mua trả lại ,giãm giá hàng mua', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6313, 'DNL', '02', 'GT', '16', '', '', '', ' d.Số thuế giá trị gia tăng không được khấu trừ', ' c.Số thuế giá trị gia tăng không được khấu trừ', '142/133,632/133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6314, 'DNL', '02', 'GT/', '17', '', '', '', ' 4.Số thuế GTGT còn được khấu trừ ,hoàn lại', ' 4.Số thuế GTGT còn được khấu trừ ,hoàn lại', 'CK-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6315, 'DNL', '02', 'GT', '', '', '', '', '    cuối kỳ  ( 16 = 10+11-12)', '    cuối kỳ  ( 16 = 10+11-12)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6316, 'DNL', '02', 'GT*', '', '', '', '', 'II - Thuế giá trị gia tăng được hoàn lại', 'II - Thuế giá trị gia tăng được hoàn lại', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6317, 'DNL', '02', 'GT/', '20', '', '', '', ' 1. Thuế giá trị gia tăng còn được hoàn lại đầu kỳ', ' 1. Thuế giá trị gia tăng còn được hoàn lại đầu kỳ', 'DK-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6318, 'DNL', '02', 'GT', '21', '', '', '', ' 2. Thuế giá trị gia tăng được hoàn lại phát sinh', ' 2. Thuế giá trị gia tăng được hoàn lại', 'NO-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6319, 'DNL', '02', 'GT', '22', '', '', '', ' 3. Thuế giá trị gia tăng đã hoàn lại', ' 3. Thuế giá trị gia tăng đã hoàn lại', 'CO-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6320, 'DNL', '02', 'GT/', '23', '', '', '', ' 4. Thuế GTGT còn được hoàn lại cuối kỳ cuối kỳ  ( 23 = 20 + 21 - 22)', ' 4. Thuế GTGT còn được hoàn lại cuối kỳ cuối kỳ  ( 23 = 20 + 21 - 22)', 'CK-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6321, 'DNL', '02', 'GT*', '', '', '', '', 'III - Thuế giá trị gia tăng được giảm', 'III - Thuế giá trị gia tăng được miển giãm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6322, 'DNL', '02', 'GT/', '30', '', '', '', ' 1. Thuế giá trị gia tăng còn được giãm đầu kỳ', ' 1. Thuế giá trị gia tăng còn được miển giãm đầu kỳ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6323, 'DNL', '02', 'GT', '31', '', '', '', ' 2. Thuế giá trị gia tăng được giảm phát sinh', ' 2. Thuế giá trị gia tăng được miển giãm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6324, 'DNL', '02', 'GT', '32', '', '', '', ' 3. Thuế giá trị gia tăng đã được giảm', ' 3. Thuế giá trị gia tăng đã được miển giãm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6325, 'DNL', '02', 'GT/', '33', '', '', '', ' 4. Thuế GTGTcòn được giãm cuối kỳ  ( 33 = 30 + 31 - 32)', ' 4. Thuế GTGTcòn được giãm cuối kỳ  ( 33 = 30 + 31 - 32)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6326, 'DNL', '02', 'GT*', '', '', '', '', 'IV - Thuế giá trị gia tăng hàng bán nội địa', 'IV - Thuế giá trị gia tăng hàng bán nội địa', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6327, 'DNL', '02', 'GT/', '40', '', '', '', ' 1.Thuế giá trị gia tăng đầu ra còn phải nộp đầu kỳ', ' 1.Thuế giá trị gia tăng đầu ra còn phải nộp đầu kỳ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6328, 'DNL', '02', 'GT', '41', '', '', '', ' 2.Thuế giá trị gia tăng đầu ra phát sinh', ' 2.Thuế giá trị gia tăng đầu ra phát sinh', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6329, 'DNL', '02', 'GT', '42', '', '', '', ' 3.Thuế giá trị gia tăng đầu vào đã khấu trừ', ' 3.Thuế giá trị gia tăng đầu vào đã khấu trừ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6330, 'DNL', '02', 'GT', '43', '', '', '', ' 4.Thuế giá trị gia tăng hàng bán bị trả lại ,bị giảm giá', ' 4.Thuế giá trị gia tăng hàng bán bị trả lại ,bị giảm giá', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6331, 'DNL', '02', 'GT', '44', '', '', '', ' 5.Thuế giá trị gia tăng được giảm trừ vào số thuế phải nộp', ' 5.Thuế giá trị gia tăng được giảm trừ vào số thuế phải nộp', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6332, 'DNL', '02', 'GT', '45', '', '', '', ' 6.Thuế giá trị gia tăng hàng bán nội địa đã nộp vào NSNN', ' 6.Thuế giá trị gia tăng hàng bán nội địa đã nộp vào NSNN', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6333, 'DNL', '02', 'GT/', '46', '', '', '', ' 7.Thuế giá trị gia tăng hàng bán nội địa còn phải nộp cuối kỳ', ' 7.Thuế giá trị gia tăng hàng bán nội địa còn phải nộp cuối kỳ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6334, 'DNL', '02', 'GT', '', '', '', '', '     ( 46 = 40+41-42-43-44-45 )', '     ( 46 = 40+41-42-43-44-45 )', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6335, 'DNL', '05', 'CB*', '', '', '', '', 'A. Tình hình tài chính', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6336, 'DNL', '05', 'CB*', '', '', '', '', 'I. Tài sản ngắn hạn', '', '1-16-129-159-1319-1399-13619-13689-1389,331,333,337,338-3389', '26192923549.00', '26281157481.00', '0.00', '0.00', '0.00'),
(6337, 'DNL', '05', 'CB', '', '', '', '', '1. Các khoản phải thu', '', '14-142,13-1319-13619-13689-1389-1399,331,337,338-3389', '23871817452.00', '25008614125.00', '0.00', '0.00', '0.00'),
(6338, 'DNL', '05', 'CB', '', '', '', '', '2. Hàng tồn kho', '', '15-159', '1827995279.00', '456275874.00', '0.00', '0.00', '0.00'),
(6339, 'DNL', '05', 'CB', '', '', '', '', '3. Tài sản ngắn hạn khác', '', '142,133,333', '170662097.00', '219741340.00', '0.00', '0.00', '0.00'),
(6340, 'DNL', '05', 'CB*', '', '', '', '', 'II. Tài sản dài hạn', '', '1319,13619,13689,1389,3389,1399,2-214-229', '1255802515.00', '1110321899.00', '0.00', '0.00', '0.00'),
(6341, 'DNL', '05', 'CB', '', '', '', '', '1. Các khoản phải thu dài hạn', '', '1319,13619,13689,1389,3389,244,1399', '-13746812.00', '-13582812.00', '0.00', '0.00', '0.00'),
(6342, 'DNL', '05', 'CB', '', '', '', '', '2. Tài sản cố định', '', '21-214,241', '1259549327.00', '1122588711.00', '0.00', '0.00', '0.00'),
(6343, 'DNL', '05', 'CB', '', '', '', '', '   - Nguyên giá', '', '21', '2481518466.00', '1842610273.00', '0.00', '0.00', '0.00'),
(6344, 'DNL', '05', 'CB', '', '', '', '', '   - Giá trị hao mòn lũy kế', '', '214', '-1516712387.00', '-1022764810.00', '0.00', '0.00', '0.00'),
(6345, 'DNL', '05', 'CB', '', '', '', '', '   - Chi phí xây dựng cơ bản dở dang', '', '241', '294743248.00', '302743248.00', '0.00', '0.00', '0.00'),
(6346, 'DNL', '05', 'CB', '', '', '', '', '3. Các khoản đầu tư tài chính dài hạn', '', '22-229', '10000000.00', '216000.00', '0.00', '0.00', '0.00'),
(6347, 'DNL', '05', 'CB', '', '', '', '01', ' - Đầu tư vào công ty con', '', '221', '10000000.00', '0.00', '0.00', '0.00', '0.00'),
(6348, 'DNL', '05', 'CB', '', '', '', '01', ' - Dự phòng giảm giá chứng khoán đầu tư dài hạn', '', '229', '0.00', '-229000.00', '0.00', '0.00', '0.00'),
(6349, 'DNL', '05', 'CB', '', '', '', '', '4. Tài sản dài hạn khác', '', '242', '0.00', '1100000.00', '0.00', '0.00', '0.00'),
(6350, 'DNL', '05', 'CB*', '', '', '', '', 'III. Nợ phải trả', '', '3,13-139,14,138,451,344', '26360678813.00', '26092557361.00', '0.00', '0.00', '0.00'),
(6351, 'DNL', '05', 'CB*', '', '', '', '', '1. Nợ ngắn hạn', '', '31,33-3319-3369,13-139-1369,14,138-1389,451,344', '26360678813.00', '26080845361.00', '0.00', '0.00', '0.00'),
(6352, 'DNL', '05', 'CB', '', '', '', '', '2. Nợ dài hạn', '', '1389,3319,3369,1369,34-344', '0.00', '1369000.00', '0.00', '0.00', '0.00'),
(6353, 'DNL', '05', 'CB*', '', '', '', '', 'IV. Vốn chủ sở hữu', '', '4-451,412,413,421,431,461', '3785462924.00', '3867850519.00', '0.00', '0.00', '0.00'),
(6354, 'DNL', '05', 'CB', '', 'ZV', '', '', '1.Vốn đầu tư của chủ sở hữu', '', '4111', '2771098563.00', '2771098563.00', '0.00', '0.00', '0.00'),
(6355, 'DNL', '05', 'CB', '', '', '', '', '2.Quỹ đầu tư phát triển', '', '414', '195602574.00', '195602574.00', '0.00', '0.00', '0.00'),
(6356, 'DNL', '05', 'CB', '', '', '', '', '3. Quỹ dự phòng tài chính', '', '415', '50479823.00', '51256823.00', '0.00', '0.00', '0.00'),
(6357, 'DNL', '05', 'CB', '', '', '', '', '4. Lợi nhuận chưa phân phối', '', '421', '0.00', '74891595.00', '0.00', '0.00', '0.00'),
(6358, 'DNL', '05', 'CB', '', '', '', '', '5. Quỹ khen thưởng, phúc lợi', '', '431', '1065151.00', '1065151.00', '0.00', '0.00', '0.00'),
(6359, 'DNL', '05', 'CB', '', '', '', '', '   - Tăng trong năm', '', 'CO431', '5243849.00', '0.00', '0.00', '0.00', '0.00'),
(6360, 'DNL', '05', 'CB', '', '', '', '', '   - Giảm trong năm', '', 'NO431', '27213449.00', '8919000.00', '0.00', '0.00', '0.00'),
(6361, 'DNL', '05', 'CB*', '', '', '', '', 'B/ Kết quả kinh doanh', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6362, 'DNL', '05', 'CB', '', 'ZD', '', '', '1.Tổng doanh thu', '', 'DT911', '38674630364.00', '27894073016.00', '0.00', '0.00', '0.00'),
(6363, 'DNL', '05', 'CB', '', '', '', '', '2.Tổng lãi (+), Lỗ (-)', '', 'LAI421', '-138971173.00', '213862768.00', '0.00', '0.00', '0.00'),
(6364, 'DNL', '05', 'CB', '', '', '', '', '   Trong đó : Lãi từ hoạt động đầu tư tài chính', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6365, 'DNL', '05', 'CB', '', '', '', '', '3.Tổng lợi nhuận sau thuế TNDN', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6366, 'DNL', '05', 'CB', '', '', '', '', '4.Tổng phải nộp ngân sách trong năm', '', 'CO333', '2326041442.00', '2101402961.00', '0.00', '0.00', '0.00'),
(6367, 'DNL', '05', 'CB*', '', '', '', '', 'C/ Các chỉ tiêu đánh giá khác', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6368, 'DNL', '05', 'CB', '', 'TS', 'ZD', '', '1. Tỷ suất lợi nhuận/doanh thu', '', 'LAI421', '0.00', '0.01', '0.00', '0.00', '0.00'),
(6369, 'DNL', '05', 'CB', '', 'TS', 'ZV', '', '2. Lợi nhuận/Vốn đầu tư của chủ sở hữu', '', 'LAI421', '-0.05', '0.08', '0.00', '0.00', '0.00'),
(6370, 'DNL', '05', 'CB', '', 'TS', 'ZV', '', '3.Tổng nợ phải trả/Vốn đầu tư của chủ sở hữu', '', '3,13-139,14,138,451,344', '9.51', '9.42', '0.00', '0.00', '0.00'),
(6371, 'DNL', '05', 'CB', '', '', '', '', '4.Tổng quỹ lương', '', 'CO334', '6537022377.00', '4825979110.00', '0.00', '0.00', '0.00'),
(6372, 'DNL', '05', 'CB', '', '', '', '', '5.Số lao động bình quân trong năm', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6373, 'DNL', '05', 'CB', '', '', '', '01', '6.Tiền lương bình quân', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6374, 'DNL', '05', 'CB', '', '', '', '01', '7.Xếp loại doanh nghiệp', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6375, 'DNL', '05', 'CB', '', '', '', '02', '6.Lợi nhuận được chia từ vốn nhà nước tại Công ty', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6376, 'DNL', '15', 'KQ*', '01', '01', '', '', '1. Doanh thu bán hàng và cung cấp dịch vụ', '1. Gross sales', '511,512/52,53,333,91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6377, 'DNL', '15', 'KQ*', '02', '03', '', '', '2. Các khoản giảm trừ doanh thu', '2. Less', 'Z( 04+05+06+07)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6378, 'DNL', '15', 'KQ_', '04', '04', '', '', '   - Chiết khấu thương mại', ' - Sales discounts', '511,512/521', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6379, 'DNL', '15', 'KQ_', '05', '05', '', '', '   - Giảm giá hàng bán', ' - Sales allowances', '511,512/532', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6380, 'DNL', '15', 'KQ_', '06', '06', '', '', '   - Hàng bán bị trả lại', ' - Sales returns', '511,512/531', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6381, 'DNL', '15', 'KQ_', '07', '07', '', '', '   - Thuế tiêu thụ đặc biệt , thuế xuất khẩu ,Thuế GTGT', ' - Excise tax ,export tax ,VAT tax', '511,512/3331,3332,3333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6382, 'DNL', '15', 'KQ_', '', '', '', '', '      Theo phương pháp trực tiếp phải nộp', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6383, 'DNL', '15', 'KQ', '10', '', '', '', '3. Doanh thu thuần về bán hàng và cung cấp DV (10 = 01-02)', '3. Net sales ( 10 = 01 - 02 )', 'Z(01-02)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6384, 'DNL', '15', 'KQ', '11', '10', '', '', '4. Giá vốn hàng bán', '4. Cost of goods sold', '91/632', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6385, 'DNL', '15', 'KQ*', '20', '', '', '', '5. Lợi nhuận gộp về bán hàng và cung cấp DV  ( 20 = 10 -11)', '5. Gross profit ( 20 = 10 -11)', 'Z(10-11)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6386, 'DNL', '15', 'KQ', '21', '08', '', '', '6. Doanh thu hoạt động tài chính', '6. Income from financial activities', '515/91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6387, 'DNL', '15', 'KQ', '22', '13', '', '', '7. Chi phí tài chính', '7. Expenses from financial activities', '91/635', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6388, 'DNL', '15', 'KQ', '23', '14', '', '', '    Trong đó : Chi phí lãi vay', '    Of witch: Interest payment', '91/6351', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6389, 'DNL', '15', 'KQ', '25', '11', '', '', '8. Chi phí bán hàng', '8. Selling expenses', '91/641', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6390, 'DNL', '15', 'KQ', '26', '12', '', '', '9. Chi phí quản lý doanh nghiệp', '9. General and administration expenses', '91/642,142', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6391, 'DNL', '15', 'KQ*', '30', '15', '', '', '10. Lợi nhuận thuần từ hoạt động kinh doanh', '10. Operating profit', 'Z(20+21-22-25-26)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6392, 'DNL', '15', 'KQ', '', '', '', '', '     [ 30 = 20 + (21-22) - (25+26)  ]', '     [ 30 = 20 + (21-22) - (25+26)  ]', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6393, 'DNL', '15', 'KQ', '31', '16', '', '', '11. Thu nhập khác', '11. Other income', '721,711/91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6394, 'DNL', '15', 'KQ', '32', '17', '', '', '12. Chi phí khác', '12. Other expenses', '91/811', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6395, 'DNL', '15', 'KQ*', '40', '18', '', '', '13. Lợi nhuận khác  ( 40 = 31 - 32 )', '13. Other profit/loss  ( 40 = 31 - 32 )', 'Z(31-32)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6396, 'DNL', '15', 'KQ*', '50', '19', '', '', '14. Tổng lợi nhuận trước thuế ( 50 = 30 + 40 )', '14. Profit before tax/ loss ( 50 = 30 + 40 )', 'Z(30+40)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6397, 'DNL', '15', 'KQ', '51', '', '', '', '15. Chi phí thuế thu nhập doanh nghiệp hiện hành', '15. Current income tax expenses', '91/8211', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6398, 'DNL', '15', 'KQ', '52', '', '', '', '16. Chi phí thuế thu nhập doanh nghiệp hoãn lại', '16. Deferred income tax liabilities', '91/8212', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6399, 'DNL', '15', 'KQ*', '60', '', '', '', '17. Lợi nhuận sau thuế thu nhập doanh nghiệp ( 60 = 50 - 51- 52 )', '17. Net profit after tax/ loss ( 60 = 50 - 51- 52 )', 'Z(50-51-52)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6400, 'DNL', '15', 'KQ', '70', '', '', '', '18. Lãi cơ bản trên cổ phiếu (*)', '18. Net profit on stock', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6401, 'DNL', '15', 'KQ', '71', '', '', '', '19. Lãi suy giảm trên cổ phiếu (*)', '19.', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6402, 'DNL', '15', 'NS*', '10', '', '', '', 'I - Thuế', 'I - Taxes', '/333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6403, 'DNL', '15', 'NS', '11', '', '', '', '1. Thuế giá trị gia tăng hàng bán nội địa', '1.Turnover tax (or VAT)', '/33311', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6404, 'DNL', '15', 'NS', '12', '', '', '', '2. Thuế GTGT hàng nhập khẩu', '2.Turnover tax (or VAT)', '/33312', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6405, 'DNL', '15', 'NS', '13', '', '', '', '3. Thuế tiêu thụ đặc biệt', '3.Excise tax', '/3332', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6406, 'DNL', '15', 'NS', '14', '', '', '', '4. Thuế xuất ,nhập khẩu', '4.Import and export duties', '/3333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6407, 'DNL', '15', 'NS', '15', '', '', '', '5. Thuế thu nhập doanh nghiệp', '5.Profit tax', '/3334', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6408, 'DNL', '15', 'NS', '16', '', '', '', '6. Thu trên vốn', '6.Capital earnings', '/3335', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6409, 'DNL', '15', 'NS', '17', '', '', '', '7. Thuế tài nguyên', '7.Land and house tax', '/3336', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6410, 'DNL', '15', 'NS', '18', '', '', '', '8. Thuế nhà đất   (33371)', '8.Land lease costs', '/33371', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6411, 'DNL', '15', 'NS', '19', '', '', '', '9. Tiền thuê đất    (33372)', '9.Land lease costs', '/33372', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6412, 'DNL', '15', 'NS', '20', '', '', '', '10. Các loại thuế khác', '10.Others', '/3338', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6413, 'DNL', '15', 'NS', '', '', '', '', '', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6414, 'DNL', '15', 'NS*', '30', '', '', '', 'II - Các khoản phải nộp khác', 'III - OTHER PAYMENTS', '/3339', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6415, 'DNL', '15', 'NS', '31', '', '', '', '1. Các khoản phụ thu                       (33391)', '1.Extra collections', '/33391', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6416, 'DNL', '15', 'NS', '32', '', '', '', '2. Các khoản phí ,lệ phí                   (33392)', '2.Fees and charges', '/33392', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6417, 'DNL', '15', 'NS', '33', '', '', '', '3. Các khoản phải nộp khác             (33393)', '3.Others', '/33393', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6418, 'DNL', '15', 'GT*', '', '', '', '', 'I - Thuế giá trị gia tăng được khấu trừ', 'I - Thuế giá trị gia tăng được khấu trừ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6419, 'DNL', '15', 'GT/', '10', '', '', '', ' 1.Số thuế GTGT còn được khấu trừ ,hoàn lại đầu kỳ', ' 1.Số thuế GTGT còn được khấu trừ ,hoàn lại đầu kỳ', 'DK-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6420, 'DNL', '15', 'GT', '11', '', '', '', ' 2.Số thuế GTGT được khấu trừ phát sinh', ' 2.Số thuế GTGT được khấu trừ phát sinh', 'NO-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6421, 'DNL', '15', 'GT', '12', '', '', '', ' 3.Số thuế GTGT đã được khấu trừ ,đã hoàn lại ,thuế GTGT', ' 3.Số thuế GTGT đã được khấu trừ ,đã hoàn lại ,thuế GTGT', 'CO-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6422, 'DNL', '15', 'GT', '', '', '', '', '    hàng mua trả lại và không được khấu trừ  ( 12 = 13 + 14 +15 )', '    hàng mua trả lại và không được khấu trừ  ( 12 = 13 + 14 +15 )', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6423, 'DNL', '15', 'GT', '', '', '', '', '    Trong đó :', '    Trong đó :', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6424, 'DNL', '15', 'GT', '13', '', '', '', ' a.Số thuế giá trị gia tăng đã khấu trừ', ' a.Số thuế giá trị gia tăng đã khấu trừ', '3331/133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6425, 'DNL', '15', 'GT', '14', '', '', '', ' b.Số thuế giá trị gia tăng đã hoàn lại', ' b.Số thuế giá trị gia tăng đã hoàn lại', '133/133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6426, 'DNL', '15', 'GT', '15', '', '', '', ' c.Số thuế giá trị gia tăng hàng mua trả lại ,giãm giá hàng mua', ' c.Số thuế giá trị gia tăng hàng mua trả lại ,giãm giá hàng mua', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6427, 'DNL', '15', 'GT', '16', '', '', '', ' d.Số thuế giá trị gia tăng không được khấu trừ', ' c.Số thuế giá trị gia tăng không được khấu trừ', '142/133,632/133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6428, 'DNL', '15', 'GT/', '17', '', '', '', ' 4.Số thuế GTGT còn được khấu trừ ,hoàn lại', ' 4.Số thuế GTGT còn được khấu trừ ,hoàn lại', 'CK-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6429, 'DNL', '15', 'GT', '', '', '', '', '    cuối kỳ  ( 16 = 10+11-12)', '    cuối kỳ  ( 16 = 10+11-12)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6430, 'DNL', '15', 'GT*', '', '', '', '', 'II - Thuế giá trị gia tăng được hoàn lại', 'II - Thuế giá trị gia tăng được hoàn lại', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6431, 'DNL', '15', 'GT/', '20', '', '', '', ' 1. Thuế giá trị gia tăng còn được hoàn lại đầu kỳ', ' 1. Thuế giá trị gia tăng còn được hoàn lại đầu kỳ', 'DK-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6432, 'DNL', '15', 'GT', '21', '', '', '', ' 2. Thuế giá trị gia tăng được hoàn lại phát sinh', ' 2. Thuế giá trị gia tăng được hoàn lại', 'NO-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6433, 'DNL', '15', 'GT', '22', '', '', '', ' 3. Thuế giá trị gia tăng đã hoàn lại', ' 3. Thuế giá trị gia tăng đã hoàn lại', 'CO-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6434, 'DNL', '15', 'GT/', '23', '', '', '', ' 4. Thuế GTGT còn được hoàn lại cuối kỳ cuối kỳ  ( 23 = 20 + 21 - 22)', ' 4. Thuế GTGT còn được hoàn lại cuối kỳ cuối kỳ  ( 23 = 20 + 21 - 22)', 'CK-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6435, 'DNL', '15', 'GT*', '', '', '', '', 'III - Thuế giá trị gia tăng được giảm', 'III - Thuế giá trị gia tăng được miển giãm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6436, 'DNL', '15', 'GT/', '30', '', '', '', ' 1. Thuế giá trị gia tăng còn được giãm đầu kỳ', ' 1. Thuế giá trị gia tăng còn được miển giãm đầu kỳ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6437, 'DNL', '15', 'GT', '31', '', '', '', ' 2. Thuế giá trị gia tăng được giảm phát sinh', ' 2. Thuế giá trị gia tăng được miển giãm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6438, 'DNL', '15', 'GT', '32', '', '', '', ' 3. Thuế giá trị gia tăng đã được giảm', ' 3. Thuế giá trị gia tăng đã được miển giãm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6439, 'DNL', '15', 'GT/', '33', '', '', '', ' 4. Thuế GTGTcòn được giãm cuối kỳ  ( 33 = 30 + 31 - 32)', ' 4. Thuế GTGTcòn được giãm cuối kỳ  ( 33 = 30 + 31 - 32)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6440, 'DNL', '15', 'GT*', '', '', '', '', 'IV - Thuế giá trị gia tăng hàng bán nội địa', 'IV - Thuế giá trị gia tăng hàng bán nội địa', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6441, 'DNL', '15', 'GT/', '40', '', '', '', ' 1.Thuế giá trị gia tăng đầu ra còn phải nộp đầu kỳ', ' 1.Thuế giá trị gia tăng đầu ra còn phải nộp đầu kỳ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6442, 'DNL', '15', 'GT', '41', '', '', '', ' 2.Thuế giá trị gia tăng đầu ra phát sinh', ' 2.Thuế giá trị gia tăng đầu ra phát sinh', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6443, 'DNL', '15', 'GT', '42', '', '', '', ' 3.Thuế giá trị gia tăng đầu vào đã khấu trừ', ' 3.Thuế giá trị gia tăng đầu vào đã khấu trừ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6444, 'DNL', '15', 'GT', '43', '', '', '', ' 4.Thuế giá trị gia tăng hàng bán bị trả lại ,bị giảm giá', ' 4.Thuế giá trị gia tăng hàng bán bị trả lại ,bị giảm giá', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6445, 'DNL', '15', 'GT', '44', '', '', '', ' 5.Thuế giá trị gia tăng được giảm trừ vào số thuế phải nộp', ' 5.Thuế giá trị gia tăng được giảm trừ vào số thuế phải nộp', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6446, 'DNL', '15', 'GT', '45', '', '', '', ' 6.Thuế giá trị gia tăng hàng bán nội địa đã nộp vào NSNN', ' 6.Thuế giá trị gia tăng hàng bán nội địa đã nộp vào NSNN', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6447, 'DNL', '15', 'GT/', '46', '', '', '', ' 7.Thuế giá trị gia tăng hàng bán nội địa còn phải nộp cuối kỳ', ' 7.Thuế giá trị gia tăng hàng bán nội địa còn phải nộp cuối kỳ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6448, 'DNL', '15', 'GT', '', '', '', '', '     ( 46 = 40+41-42-43-44-45 )', '     ( 46 = 40+41-42-43-44-45 )', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6449, 'DNN', '98', 'KQ*', '01', '', '', '', ' - Tổng doanh thu', ' - Gross turnover', '51/52,53,333,91', '197936711.00', '37074376658.00', '5645.00', '0.00', '0.00'),
(6450, 'DNN', '98', 'KQ', '02', '', '', '', '   Trong đó : doanh thu hàng xuất khẩu     (51119)', '   of which : turnover of export', '/51119', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6451, 'DNN', '98', 'KQ*', '03', '', '', '', ' - Các khoản giãm trừ ( 04+05+06+07 )', ' - Deductions (04+05+06+07)', 'Z(04+05+06+07)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6452, 'DNN', '98', 'KQ', '04', '', '', '', '   + Chiết khấu', '   + Discounts', '51/521', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6453, 'DNN', '98', 'KQ', '05', '', '', '', '   + Giãm giá', '   + Devaluation', '51/532', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6454, 'DNN', '98', 'KQ', '06', '', '', '', '   + Giá trị hàng bán bị trả lại', '   + Sold goods to be returned', '51/531', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6455, 'DNN', '98', 'KQ', '07', '', '', '', '   + Thuế doanh thu ,xuất khẩu phải nộp', '   + Payables of turnover and export tax', '51/3331,3332,3333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6456, 'DNN', '98', 'KQ*', '10', '', '', '', '1.Doanh thu thuần ( 01-03 )', '1.Net income (01-03)', 'Z(01-03)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6457, 'DNN', '98', 'KQ*', '11', '', '', '', '2.Giá vốn hàng bán', '2.Original rate of sold goods', '91/632', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6458, 'DNN', '98', 'KQ*', '20', '', '', '', '3.Lợi tức gộp ( 10-11)', '3.Gross profit (10-11)', 'Z(10-11)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6459, 'DNN', '98', 'KQ*', '21', '', '', '', '4.Chi phí bán hàng', '4.Sale costs', '91/641', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6460, 'DNN', '98', 'KQ*', '22', '', '', '', '5.Chi phí quản lý doanh nghiệp', '5.Enteprise management costs', '91/642,142', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6461, 'DNN', '98', 'KQ*', '30', '', '', '', '6.Lợi tức thuần từ hoạt động kinh doanh  ( 20-21-22)', '6.Net profit from business  ( 20-21-22)', 'Z(20-21-22)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6462, 'DNN', '98', 'KQ', '31', '', '', '', ' - Thu nhập hoạt động tài chính', ' - Income from financial activities', '/711', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6463, 'DNN', '98', 'KQ', '32', '', '', '', ' - Thuế doanh thu phải nộp', ' - Payables of turnover', '711/333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6464, 'DNN', '98', 'KQ', '33', '', '', '', ' - Chi phí hoạt động tài chính', ' - Costs for financial activities', '91/811', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6465, 'DNN', '98', 'KQ*', '40', '', '', '', '7.Lợi tức hoạt động tài chính ( 31-32 -33)', '7.Profit from financial activities', 'Z(31-32-33)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6466, 'DNN', '98', 'KQ', '41', '', '', '', ' - Các khoản thu nhập bất thường', ' - Unforseen income', '/721', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6467, 'DNN', '98', 'KQ', '42', '', '', '', ' - Thuế doanh thu phải nộp', ' - Payables of turnover', '721/333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6468, 'DNN', '98', 'KQ', '43', '', '', '', ' - Chi phí bất thường', ' - Unforseen costs', '91/821', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6469, 'DNN', '98', 'KQ*', '50', '', '', '', '8.Lợi tức bất thường ( 41-42 -43)', '8.Unforseen profit (41-42)', 'Z(41-42-43)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6470, 'DNN', '98', 'KQ*', '60', '', '', '', '9.Tổng lợi tức trước thuế ( 30+40+50 )', '9.Gross profit before tax (30+40+50)', 'Z(30+40+50)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6471, 'DNN', '98', 'KQ*', '70', '', '', '', '10.Lợi tức phải nộp', '10.Payable profit tax', '421/3334', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6472, 'DNN', '98', 'KQ*', '80', '', '', '', '11.Lợi tức sau thuế ( 60 -70 )', '11.Profit after tax (60-70)', 'Z(60-70)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6473, 'DNN', '--', '---', '--', '', '', '', '----------------------------------------', '----------------------------------------', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6474, 'DNN', '98', 'NS*', '', '', '', '', 'I - Thuế', 'I - Taxes', '/333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6475, 'DNN', '98', 'NS', '', '', '', '', '1. Thuế doanh thu ( hoặc V.A.T )', '1.Turnover tax (or VAT)', '/3331', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6476, 'DNN', '98', 'NS', '', '', '', '', '2. Thuế tiêu thụ đặc biệt', '2.Excise tax', '/3332', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6477, 'DNN', '98', 'NS', '', '', '', '', '3. Thuế xuất ,nhập khẩu', '3.Import and export duties', '/3333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6478, 'DNN', '98', 'NS', '', '', '', '', '4. Thuế lợi tức', '4.Profit tax', '/3334', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6479, 'DNN', '98', 'NS', '', '', '', '', '5. Thu trên vốn', '5.Capital earnings', '/3335', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6480, 'DNN', '98', 'NS', '', '', '', '', '6. Thuế tài nguyên', '6.Land and house tax', '/3336', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6481, 'DNN', '98', 'NS', '', '', '', '', '7. Thuế nhà đất ,tiền thuê đất', '7.Land lease costs', '/3337', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6482, 'DNN', '98', 'NS', '', '', '', '', '9. Các loại thuế khác', '9.Others', '/3338', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6483, 'DNN', '98', 'NS', '', '', '', '', '', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6484, 'DNN', '98', 'NS*', '', '', '', '', 'II - Các khoản phải nộp khác', 'III - OTHER PAYMENTS', '/3339', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6485, 'DNN', '98', 'NS', '', '', '', '', '1. Các khoản phụ thu                       (33391)', '1.Extra collections', '/33391', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6486, 'DNN', '98', 'NS', '', '', '', '', '2. Các khoản phí ,lệ phí                   (33392)', '2.Fees and charges', '/33392', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6487, 'DNN', '98', 'NS', '', '', '', '', '3. Các khoản phải nộp khác            (33393)', '3.Others', '/33393', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6488, 'DNN', '04', 'CB*', '01', '', '', '', 'Tài sản lưu động', 'Current assers', '1-129-139-154-159,3', '46098887435.00', '24403939345.00', '0.00', '0.00', '0.00'),
(6489, 'DNN', '04', 'CB', '', '', '', '', ' - Vốn bằng tiền', ' - Capital in cash', '11', '806071972.00', '322448721.00', '0.00', '0.00', '0.00'),
(6490, 'DNN', '04', 'CB', '', '', '', '', ' - Đầu tư tài chính ngắn hạn', ' - Long-term investments', '12-129', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6491, 'DNN', '04', 'CB', '', '', '', '', ' - Các khoản nợ phải thu', ' - Accounts Receivable', '13-1381-139,3', '43019685085.00', '23815230505.00', '0.00', '0.00', '0.00'),
(6492, 'DNN', '04', 'CB', '', '', '', '', '    + Các khoản nợ khó đòi', '    + Doubtful debt', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6493, 'DNN', '04', 'CB', '', '', '', '', ' - Hàng tồn kho', ' - Inventories', '15-154-159', '38648175.00', '39011075.00', '0.00', '0.00', '0.00'),
(6494, 'DNN', '04', 'CB', '', '', '', '', ' - Tài sản lưu động khác', ' - Orther current assets', '14,16', '2234482203.00', '227249044.00', '0.00', '0.00', '0.00'),
(6495, 'DNN', '04', 'CB*', '02', '', '', '', 'Tài sản cố định', 'Fixed assets', '2-214-229', '1126755120.00', '1269549327.00', '0.00', '0.00', '0.00'),
(6496, 'DNN', '04', 'CB', '', '', '', '', ' - Nguyên giá tài sản cố định', ' - Cost', '21', '2602579084.00', '2481518466.00', '0.00', '0.00', '0.00'),
(6497, 'DNN', '04', 'CB', '', '', '', '', ' - Giá trị hao mòn lũy kế', ' - Accumulated Depreciation', '214', '-1780567212.00', '-1516712387.00', '0.00', '0.00', '0.00'),
(6498, 'DNN', '04', 'CB', '', '', '', '', ' - Đầu tư tài chính dài hạn', ' - Long-term investments', '22-229', '10000000.00', '10000000.00', '0.00', '0.00', '0.00'),
(6499, 'DNN', '04', 'CB', '', '', '', '', ' - Chi phí XDCB dở dang', ' - Construction in progress', '241', '294743248.00', '294743248.00', '0.00', '0.00', '0.00'),
(6500, 'DNN', '04', 'CB', '', '', '', '', ' - Các khoản ký quỹ ,ký cược dài hạn', ' - Long-term deposits', '244', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6501, 'DNN', '04', 'CB*', '03', '', '', '', 'Nợ ngắn hạn', 'Short-term liabilities', '31,33-3381-335,13-139', '47447766387.00', '25315631247.00', '0.00', '0.00', '0.00'),
(6502, 'DNN', '04', 'CB', '', '', '', '', ' - Vay ngắn hạn quá hạn trả', ' - Short-term borrowings of which overdue', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6503, 'DNN', '04', 'CB*', '04', '', '', '', 'Nợ dài hạn', 'Long-term Liabilities', '34-344', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6504, 'DNN', '04', 'CB', '', '', '', '', ' - Vay dài hạn quá hạn trả', ' - Long-term borrowings of which overdue', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6505, 'DNN', '04', 'CB*', '05', '', '', '', 'Vốn kinh doanh', 'Paid in capital', '4111,4112,441', '3377828142.00', '3377828142.00', '0.00', '0.00', '0.00'),
(6506, 'DNN', '04', 'CB', '', '', '', '', ' - Vốn cố định       ( 41111 ,41121 )', ' - Fixed assets       ( 41111 ,41121 )', '41111,41121', '2572258123.00', '2572258123.00', '0.00', '0.00', '0.00'),
(6507, 'DNN', '04', 'CB', '', '', '', '', ' - Vốn lưu động     ( 41112 ,41122 )', ' - Current assets    ( 41112 ,41122 )', '41112,41122', '757269371.00', '757269371.00', '0.00', '0.00', '0.00'),
(6508, 'DNN', '04', 'CB', '', '', '', '', ' - Vốn xây dựng cơ bản', ' - Funds for capital expenditures', '441', '48300648.00', '48300648.00', '0.00', '0.00', '0.00'),
(6509, 'DNN', '04', 'CB*', '06', '', '', '', 'Các quỹ', 'Funds', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6510, 'DNN', '04', 'CB*', '', '', '', '', ' - Quỹ phát triển kinh doanh', ' - Business development funds', 'CK4141', '195602574.00', '195602574.00', '0.00', '0.00', '0.00'),
(6511, 'DNN', '04', 'CB', '', '', '', '', '   + Số dư đầu năm', '   + Opening', 'DK4141', '195602574.00', '195602574.00', '0.00', '0.00', '0.00'),
(6512, 'DNN', '04', 'CB', '', '', '', '', '   + Đã trích trong năm', '   + Increase', 'CO4141', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6513, 'DNN', '04', 'CB', '', '', '', '', '   + Thực chi trong năm', '   + Decrease', 'NO4141', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6514, 'DNN', '04', 'CB*', '', '', '', '', ' - Quỹ dự trữ tài chính', ' - Reserved funds', 'CK415', '50479823.00', '50479823.00', '0.00', '0.00', '0.00'),
(6515, 'DNN', '04', 'CB', '', '', '', '', '   + Số dư đầu năm', '   + Opening', 'DK415', '50479823.00', '50479823.00', '0.00', '0.00', '0.00'),
(6516, 'DNN', '04', 'CB', '', '', '', '', '   + Đã trích trong năm', '   + Increase', 'CO415', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6517, 'DNN', '04', 'CB', '', '', '', '', '   + Thực chi trong năm', '   + Decrease', 'NO415', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6518, 'DNN', '04', 'CB*', '', '', '', '', ' - Quỹ khen thưởng ,phúc lợi', ' - Bonus & welfare funds', 'CK431', '1265151.00', '1065151.00', '0.00', '0.00', '0.00'),
(6519, 'DNN', '04', 'CB', '', '', '', '', '   + Số dư đầu năm', '   + Opening', 'DK431', '23034751.00', '23034751.00', '0.00', '0.00', '0.00'),
(6520, 'DNN', '04', 'CB', '', '', '', '', '   + Đã trích trong năm', '   + Increase', 'CO431', '0.00', '5243849.00', '0.00', '0.00', '0.00'),
(6521, 'DNN', '04', 'CB', '', '', '', '', '   + Thực chi trong năm', '   + Decrease', 'NO431', '21769600.00', '27213449.00', '0.00', '0.00', '0.00'),
(6522, 'DNN', '04', 'CB*', '', '', '', '', ' - Quỹ trợ cấp mất việc làm', ' - Workless allowances funds', 'CK416', '25401330.00', '0.00', '0.00', '0.00', '0.00'),
(6523, 'DNN', '04', 'CB', '', '', '', '', '   + Số dư đầu năm', '   + Opening', 'DK416', '25401330.00', '25401330.00', '0.00', '0.00', '0.00'),
(6524, 'DNN', '04', 'CB', '', '', '', '', '   + Đã trích trong năm', '   + Increase', 'CO416', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6525, 'DNN', '04', 'CB', '', '', '', '', '   + Thực chi trong năm', '   + Decrease', 'NO416', '0.00', '25401330.00', '0.00', '0.00', '0.00'),
(6526, 'DNN', '04', 'CB*', '08', '', '', '', 'Kết quả kinh doanh', 'Income summary', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6527, 'DNN', '04', 'CB', '', '', '', '', ' - Sản lượng sản phẩm chủ yếu', ' - Quantity of main Products', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6528, 'DNN', '04', 'CB', '', '', '', '', ' - Tổng doanh thu', ' - Gross tunover', 'DT911', '5152041080.00', '38674630364.00', '0.00', '0.00', '0.00'),
(6529, 'DNN', '04', 'CB', '', '', '', '', ' - Tổng chi phí', ' - Total costs', 'CP911', '5044490680.00', '38813601537.00', '0.00', '0.00', '0.00'),
(6530, 'DNN', '04', 'CB', '', '', '', '', ' - Tổng lãi ,lổ', ' - Total profits,loss', 'LAI421', '107550400.00', '-138971173.00', '0.00', '0.00', '0.00'),
(6531, 'DNN', '04', 'CB*', '09', '', '', '', 'Nộp ngân sách nhà nước', 'Payable to state budget', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6532, 'DNN', '04', 'CB', '', '', '', '', ' - Tổng số thuế phải nộp trong năm', ' - Total taxes payable in year', 'CO333', '913181414.00', '2326041442.00', '0.00', '0.00', '0.00'),
(6533, 'DNN', '04', 'CB', '', '', '', '', '    + Thuế lợi tức', '    + Profits tax', 'CO3334', '105022360.00', '105022360.00', '0.00', '0.00', '0.00'),
(6534, 'DNN', '04', 'CB', '', '', '', '', ' - Tổng số thuế đã nộp', ' - Total paid taxes', 'NO333', '431339098.00', '2094942413.00', '0.00', '0.00', '0.00'),
(6535, 'DNN', '04', 'CB', '', '', '', '', '    + Thuế lợi tức', '    + Profits tax', 'NO3334', '77939178.00', '77939178.00', '0.00', '0.00', '0.00'),
(6536, 'DNN', '04', 'CB*', '10', '', '', '', 'Lao động', 'Labour', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6537, 'DNN', '04', 'CB', '', '', '', '', ' - Hợp đồng ngắn hạn', ' - Short-term contract', '', '550.00', '550.00', '0.00', '0.00', '0.00'),
(6538, 'DNN', '04', 'CB', '', '', '', '', ' - Hợp đồng dài hạn', ' - Long-term contract', '', '55.00', '55.00', '0.00', '0.00', '0.00'),
(6539, 'DNN', '04', 'CB*', '11', '', '', '', 'Thu nhập', 'Income', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6540, 'DNN', '04', 'CB', '', '', '', '', ' - Tổng quỹ lương', ' - Toatal salaries', 'CO-334', '1117166944.00', '6536522377.00', '0.00', '0.00', '0.00'),
(6541, 'DNN', '04', 'CB', '', '', '', '', ' - Thu nhập khác', ' - Other income', 'NO-431', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6542, 'DNN', '04', 'CB', '', '', '', '', '   + Tiền lương bình quân', '   + Average salaries', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6543, 'DNN', '04', 'CB', '', '', '', '', '   + Thu nhập bình quân', '   + Average income', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6544, 'DNN', '', '---', '--', '', '', '', '--------------------------------------------------', '--------------------------------------------------', '-------------------------', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6545, 'DNN', '99', 'KQ*', '01', '', '', '', ' - Tổng doanh thu', ' - Gross turnover', '51/52,53,333,91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6546, 'DNN', '99', 'KQ', '02', '', '', '', '   Trong đó : doanh thu hàng xuất khẩu     (51119)', '   of which : turnover of export', '/51119', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6547, 'DNN', '99', 'KQ*', '03', '', '', '', ' - Các khoản giãm trừ ( 05+06+07 )', ' - Deductions (04+05+06+07)', 'Z(05+06+07)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6548, 'DNN', '99', 'KQ', '05', '', '', '', '   + Giãm giá hàng bán', '   + Devaluation', '51/532', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6549, 'DNN', '99', 'KQ', '06', '', '', '', '   + Hàng bán bị trả lại', '   + Sold goods to be returned', '51/531', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6550, 'DNN', '99', 'KQ', '07', '', '', '', '   + Thuế tiêu thụ đặc biệt , xuất khẩu phải nộp', '   + Payables of turnover and export tax', '51/3331,3332,3333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6551, 'DNN', '99', 'KQ*', '10', '', '', '', '1.Doanh thu thuần ( 01-03 )', '1.Net income (01-03)', 'Z(01-03)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6552, 'DNN', '99', 'KQ*', '11', '', '', '', '2.Giá vốn hàng bán', '2.Original rate of sold goods', '91/632', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6553, 'DNN', '99', 'KQ*', '20', '', '', '', '3.Lợi nhuận gộp ( 10-11)', '3.Gross profit (10-11)', 'Z(10-11)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6554, 'DNN', '99', 'KQ*', '21', '', '', '', '4.Chi phí bán hàng', '4.Sale costs', '91/641', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6555, 'DNN', '99', 'KQ*', '22', '', '', '', '5.Chi phí quản lý doanh nghiệp', '5.Enteprise management costs', '91/642,142', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6556, 'DNN', '99', 'KQ*', '30', '', '', '', '6.Lợi nhuận thuần từ hoạt động kinh doanh  ( 20-21-22)', '6.Net profit from business  ( 20-21-22)', 'Z(20-21-22)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6557, 'DNN', '99', 'KQ', '31', '', '', '', ' - Thu nhập hoạt động tài chính', ' - Income from financial activities', '711/91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6558, 'DNN', '99', 'KQ', '32', '', '', '', ' - Chi phí hoạt động tài chính', ' - Costs for financial activities', '91/811', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6559, 'DNN', '99', 'KQ*', '40', '', '', '', '7.Lợi nhuận hoạt động tài chính ( 31-32 )', '7.Profit from financial activities', 'Z(31-32)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6560, 'DNN', '99', 'KQ', '41', '', '', '', ' - Các khoản thu nhập bất thường', ' - Unforseen income', '721/91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6561, 'DNN', '99', 'KQ', '42', '', '', '', ' - Chi phí bất thường', ' - Unforseen costs', '91/821', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6562, 'DNN', '99', 'KQ*', '50', '', '', '', '8.Lợi nhuận bất thường ( 41-42 )', '8.Unforseen profit (41-42)', 'Z(41-42)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6563, 'DNN', '99', 'KQ*', '60', '', '', '', '9.Tổng lợi nhuận trước thuế ( 30+40+50 )', '9.Gross profit before tax (30+40+50)', 'Z(30+40+50)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6564, 'DNN', '99', 'KQ*', '70', '', '', '', '10.Thuế thu nhập doanh nghiệp phải nộp', '10.Payable profit tax', '421/3334', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6565, 'DNN', '99', 'KQ*', '80', '', '', '', '11.Lợi nhuận sau thuế ( 60 -70 )', '11.Profit after tax (60-70)', 'Z(60-70)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6566, 'DNN', '--', '---', '--', '', '', '', '----------------------------------------', '----------------------------------------', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6567, 'DNN', '99', 'NS*', '10', '', '', '', 'I - Thuế', 'I - Taxes', '/333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6568, 'DNN', '99', 'NS', '11', '', '', '', '1. Thuế giá trị gia tăng hàng bán nội địa', '1.Turnover tax (or VAT)', '/33311', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6569, 'DNN', '99', 'NS', '12', '', '', '', '2. Thuế GTGT hàng nhập khẩu', '2.Turnover tax (or VAT)', '/33312', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6570, 'DNN', '99', 'NS', '13', '', '', '', '3. Thuế tiêu thụ đặc biệt', '3.Excise tax', '/3332', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6571, 'DNN', '99', 'NS', '14', '', '', '', '4. Thuế xuất ,nhập khẩu', '4.Import and export duties', '/3333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6572, 'DNN', '99', 'NS', '15', '', '', '', '5. Thuế thu nhập doanh nghiệp', '5.Profit tax', '/3334', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6573, 'DNN', '99', 'NS', '16', '', '', '', '6. Thu trên vốn', '6.Capital earnings', '/3335', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6574, 'DNN', '99', 'NS', '17', '', '', '', '7. Thuế tài nguyên', '7.Land and house tax', '/3336', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6575, 'DNN', '99', 'NS', '18', '', '', '', '8. Thuế nhà đất', '8.Land lease costs', '/33371', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6576, 'DNN', '99', 'NS', '19', '', '', '', '9. Tiền thuê đất', '9.Land lease costs', '/33372', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6577, 'DNN', '99', 'NS', '20', '', '', '', '10. Các loại thuế khác', '10.Others', '/3338', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6578, 'DNN', '99', 'NS', '', '', '', '', '', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6579, 'DNN', '99', 'NS*', '30', '', '', '', 'II - Các khoản phải nộp khác', 'III - OTHER PAYMENTS', '/3339', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6580, 'DNN', '99', 'NS', '31', '', '', '', '1. Các khoản phụ thu                       (33391)', '1.Extra collections', '/33391', '0.00', '0.00', '0.00', '0.00', '0.00');
INSERT INTO `ketquakd` (`id`, `chedokt`, `kyhieu`, `swt`, `maso`, `kyhieu1`, `kyhieu2`, `tminh`, `chitieu`, `chitieuu`, `cachtinh`, `kytruoc`, `kynay`, `luyke`, `luykeno`, `luykeco`) VALUES
(6581, 'DNN', '99', 'NS', '32', '', '', '', '2. Các khoản phí ,lệ phí                   (33392)', '2.Fees and charges', '/33392', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6582, 'DNN', '99', 'NS', '33', '', '', '', '3. Các khoản phải nộp khác             (33393)', '3.Others', '/33393', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6583, 'DNN', '--', '---', '--', '', '', '', '--------------------------------------------------', '--------------------------------------------------', '-------------------------', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6584, 'DNN', '99', 'GT*', '', '', '', '', 'I - Thuế giá trị gia tăng được khấu trừ', 'I - Thuế giá trị gia tăng được khấu trừ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6585, 'DNN', '99', 'GT/', '10', '', '', '', ' 1.Số thuế GTGT còn được khấu trừ ,hoàn lại đầu kỳ', ' 1.Số thuế GTGT còn được khấu trừ ,hoàn lại đầu kỳ', 'DK-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6586, 'DNN', '99', 'GT', '11', '', '', '', ' 2.Số thuế GTGT được khấu trừ phát sinh', ' 2.Số thuế GTGT được khấu trừ phát sinh', 'NO-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6587, 'DNN', '99', 'GT', '12', '', '', '', ' 3.Số thuế GTGT đã được khấu trừ ,đã hoàn lại ,thuế GTGT', ' 3.Số thuế GTGT đã được khấu trừ ,đã hoàn lại ,thuế GTGT', 'CO-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6588, 'DNN', '99', 'GT', '', '', '', '', '    hàng mua trả lại và không được khấu trừ  ( 12 = 13 + 14 +15 )', '    hàng mua trả lại và không được khấu trừ  ( 12 = 13 + 14 +15 )', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6589, 'DNN', '99', 'GT', '', '', '', '', '    Trong đó :', '    Trong đó :', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6590, 'DNN', '99', 'GT', '13', '', '', '', ' a.Số thuế giá trị gia tăng đã khấu trừ', ' a.Số thuế giá trị gia tăng đã khấu trừ', '3331/133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6591, 'DNN', '99', 'GT', '14', '', '', '', ' b.Số thuế giá trị gia tăng đã hoàn lại', ' b.Số thuế giá trị gia tăng đã hoàn lại', '133/133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6592, 'DNN', '99', 'GT', '15', '', '', '', ' c.Số thuế giá trị gia tăng hàng mua trả lại ,giãm giá hàng mua', ' c.Số thuế giá trị gia tăng hàng mua trả lại ,giãm giá hàng mua', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6593, 'DNN', '99', 'GT', '16', '', '', '', ' d.Số thuế giá trị gia tăng không được khấu trừ', ' c.Số thuế giá trị gia tăng không được khấu trừ', '142/133,632/133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6594, 'DNN', '99', 'GT/', '17', '', '', '', ' 4.Số thuế GTGT còn được khấu trừ ,hoàn lại', ' 4.Số thuế GTGT còn được khấu trừ ,hoàn lại', 'CK-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6595, 'DNN', '99', 'GT', '', '', '', '', '    cuối kỳ  ( 16 = 10+11-12)', '    cuối kỳ  ( 16 = 10+11-12)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6596, 'DNN', '99', 'GT*', '', '', '', '', 'II - Thuế giá trị gia tăng được hoàn lại', 'II - Thuế giá trị gia tăng được hoàn lại', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6597, 'DNN', '99', 'GT/', '20', '', '', '', ' 1. Thuế giá trị gia tăng còn được hoàn lại đầu kỳ', ' 1. Thuế giá trị gia tăng còn được hoàn lại đầu kỳ', 'DK-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6598, 'DNN', '99', 'GT', '21', '', '', '', ' 2. Thuế giá trị gia tăng được hoàn lại phát sinh', ' 2. Thuế giá trị gia tăng được hoàn lại', 'NO-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6599, 'DNN', '99', 'GT', '22', '', '', '', ' 3. Thuế giá trị gia tăng đã hoàn lại', ' 3. Thuế giá trị gia tăng đã hoàn lại', 'CO-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6600, 'DNN', '99', 'GT/', '23', '', '', '', ' 4. Thuế GTGT còn được hoàn lại cuối kỳ cuối kỳ  ( 23 = 20 + 21 - 22)', ' 4. Thuế GTGT còn được hoàn lại cuối kỳ cuối kỳ  ( 23 = 20 + 21 - 22)', 'CK-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6601, 'DNN', '99', 'GT*', '', '', '', '', 'III - Thuế giá trị gia tăng được giảm', 'III - Thuế giá trị gia tăng được miển giãm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6602, 'DNN', '99', 'GT/', '30', '', '', '', ' 1. Thuế giá trị gia tăng còn được giãm đầu kỳ', ' 1. Thuế giá trị gia tăng còn được miển giãm đầu kỳ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6603, 'DNN', '99', 'GT', '31', '', '', '', ' 2. Thuế giá trị gia tăng được giảm phát sinh', ' 2. Thuế giá trị gia tăng được miển giãm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6604, 'DNN', '99', 'GT', '32', '', '', '', ' 3. Thuế giá trị gia tăng đã được giảm', ' 3. Thuế giá trị gia tăng đã được miển giãm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6605, 'DNN', '99', 'GT/', '33', '', '', '', ' 4. Thuế GTGTcòn được giãm cuối kỳ  ( 33 = 30 + 31 - 32)', ' 4. Thuế GTGTcòn được giãm cuối kỳ  ( 33 = 30 + 31 - 32)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6606, 'DNN', '99', 'GT*', '', '', '', '', 'IV - Thuế giá trị gia tăng hàng bán nội địa', 'IV - Thuế giá trị gia tăng hàng bán nội địa', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6607, 'DNN', '99', 'GT/', '40', '', '', '', ' 1.Thuế giá trị gia tăng đầu ra còn phải nộp đầu kỳ', ' 1.Thuế giá trị gia tăng đầu ra còn phải nộp đầu kỳ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6608, 'DNN', '99', 'GT', '41', '', '', '', ' 2.Thuế giá trị gia tăng đầu ra phát sinh', ' 2.Thuế giá trị gia tăng đầu ra phát sinh', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6609, 'DNN', '99', 'GT', '42', '', '', '', ' 3.Thuế giá trị gia tăng đầu vào đã khấu trừ', ' 3.Thuế giá trị gia tăng đầu vào đã khấu trừ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6610, 'DNN', '99', 'GT', '43', '', '', '', ' 4.Thuế giá trị gia tăng hàng bán bị trả lại ,bị giảm giá', ' 4.Thuế giá trị gia tăng hàng bán bị trả lại ,bị giảm giá', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6611, 'DNN', '99', 'GT', '44', '', '', '', ' 5.Thuế giá trị gia tăng được giảm trừ vào số thuế phải nộp', ' 5.Thuế giá trị gia tăng được giảm trừ vào số thuế phải nộp', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6612, 'DNN', '99', 'GT', '45', '', '', '', ' 6.Thuế giá trị gia tăng hàng bán nội địa đã nộp vào NSNN', ' 6.Thuế giá trị gia tăng hàng bán nội địa đã nộp vào NSNN', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6613, 'DNN', '99', 'GT/', '46', '', '', '', ' 7.Thuế giá trị gia tăng hàng bán nội địa còn phải nộp cuối kỳ', ' 7.Thuế giá trị gia tăng hàng bán nội địa còn phải nộp cuối kỳ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6614, 'DNN', '99', 'GT', '', '', '', '', '     ( 46 = 40+41-42-43-44-45 )', '     ( 46 = 40+41-42-43-44-45 )', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6615, 'DNN', '==', '===', '==', '', '', '', '======================================================================', '======================================================================', '=========================', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6616, 'DNN', '', 'GT1', 'A', '10', '', '', 'Không phát sinh hoạt động mua, bán trong kỳ (đánh dấu &quot;X&quot;)', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6617, 'DNN', '', 'GT1', 'B', '', '11', '', 'Thuế GTGT còn được khấu trừ kỳ trước chuyển sang', 'Sales of merchandise & service', '', '0.00', '1257336591.00', '0.00', '0.00', '0.00'),
(6618, 'DNN', '', 'GT1', 'C', '', '', '', 'Kê khai thuế GTGT phải nộp Ngân sách nhà nước', 'VAT of merchandise & service', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6619, 'DNN', '', 'GT1', 'I', '', '', '', 'Hàng hoá, dịch vụ (HHDV) mua vào', ' a -  0%', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6620, 'DNN', '', 'GT1', '1', '12', '13', 'Z', 'Hàng hoá, dịch vụ mua vào trong kỳ ( [12]=[14]+[16]; [13]=[15]+[17] )', ' b -  5%', '', '622948163901.00', '4804073072.00', '0.00', '0.00', '0.00'),
(6621, 'DNN', '', 'GT1', 'a', '14', '15', '', '        - Hàng hoá, dịch vụ mua vào trong nước', ' c -  10%', '', '622948163901.00', '4804073072.00', '0.00', '0.00', '0.00'),
(6622, 'DNN', '', 'GT1', 'b', '16', '17', '', '        - Hàng hoá, dịch vụ nhập khẩu', ' d -  20%', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6623, 'DNN', '', 'GT1', '2', '', '', '', 'Điều chỉnh thuế GTGT của HHDV mua vào các kỳ trước', 'Purchase of merchandise & service', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6624, 'DNN', '', 'GT1', 'a', '18', '19', '', '        - Điều chỉnh tăng', 'VAT Purchase of merchandise & service', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6625, 'DNN', '', 'GT1', 'b', '20', '21', '', '        - Điều chỉnh giảm', 'VAT Deductions', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6626, 'DNN', '', 'GT1', '3', '', '22', 'Z', 'Tổng số thuế GTGT của HHDV mua vào ( [22] = [13] + [19] - [21] )', 'Payables of VAT  (+) or returned (-) in period', 'X', '0.00', '4804073072.00', '0.00', '0.00', '0.00'),
(6627, 'DNN', '', 'GT1', '4', '', '23', 'Z', 'Tổng số thuế GTGT được khấu trừ kỳ này', 'Outstanding prior period of VAT', 'X', '0.00', '4804073072.00', '0.00', '0.00', '0.00'),
(6628, 'DNN', '', 'GT1', 'II', '', '', '', 'Hàng hóa ,dịch vụ bán ra', ' a - Short', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6629, 'DNN', '', 'GT1', '1', '24', '25', 'Z', 'Hàng hoá, dịch vụ bán ra trong kỳ ( [24]=[26]+[27] ; [25]=[28] )', ' b - Over', 'X', '1129060689576.00', '5040677435.00', '0.00', '0.00', '0.00'),
(6630, 'DNN', '', 'GT1', '11', '26', '', '', 'Hàng hóa ,dịch vụ bán ra không chịu thuế GTGT', 'Paid of VAT in month', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6631, 'DNN', '', 'GT1', '12', '', '', '', 'Hàng hóa ,dịch vụ bán ra chịu thuế GTGT', '  Include other Local', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6632, 'DNN', '', 'GT1', '', '27', '28', 'Z', '    ( [27] = [29]+[30]+[32] ; [28] =[31]+[33] )', 'Returned of VAT in month', 'X', '1129060689576.00', '5040677435.00', '0.00', '0.00', '0.00'),
(6633, 'DNN', '', 'GT1', 'a', '29', '', '', '        - Hàng hóa ,dịch vụ bán ra chịu thuế suất 0%', '', '', '556002346305.00', '52795446664.00', '0.00', '0.00', '0.00'),
(6634, 'DNN', '', 'GT1', 'b', '30', '31', '', '        - Hàng hóa ,dịch vụ bán ra chịu thuế suất 5%', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6635, 'DNN', '', 'GT1', 'c', '32', '33', '', '        - Hàng hóa ,dịch vụ bán ra chịu thuế suất 10%', '', '', '573058343271.00', '5040677435.00', '0.00', '0.00', '0.00'),
(6636, 'DNN', '', 'GT1', '2', '', '', '', 'Điều chỉnh thuế GTGT của HHDV bán ra các kỳ trước', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6637, 'DNN', '', 'GT1', 'a', '34', '35', '', '        - Điều chỉnh tăng', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6638, 'DNN', '', 'GT1', 'b', '36', '37', '', '        - Điều chỉnh giảm', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6639, 'DNN', '', 'GT1', '3', '', '', '', 'Tổng doanh thu và thuế GTGT của DVHH bán ra', 'Payables of VAT in this month', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6640, 'DNN', '', 'GT1', '', '38', '39', 'Z', '    ( [38] = [24]+[34]-[36] ; [39] =[25]+[35]-[37] )', '', '', '1129060689576.00', '5040677435.00', '0.00', '0.00', '0.00'),
(6641, 'DNN', '', 'GT1', 'II', '', '', '', 'Xác định nghĩa vụ thuế GTGT phải nộp trong kỳ :', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6642, 'DNN', '', 'GT1', '1', '', '40', 'Z', 'Thuế GTGT phải nộp trong kỳ ( [40] = [39] - [23] - [11] )', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6643, 'DNN', '', 'GT1', '2', '', '41', 'Z', 'Thuế GTGT chưa khấu trừ hết kỳ này  ( [41] = [39] - [23] - [11] )', '', '', '0.00', '1257336591.00', '0.00', '0.00', '0.00'),
(6644, 'DNN', '', 'GT1', '21', '', '42', '', 'Thuế GTGT đề nghị hoàn kỳ này', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6645, 'DNN', '', 'GT1', '22', '', '43', 'Z', 'Thuế GTGT còn được khấu trừ chuyển sang kỳ sau  ( [43] = [41] - [42] )', '', '', '0.00', '1257336591.00', '0.00', '0.00', '0.00'),
(6646, 'DNN', '==', '===', '==', '', '', '', '======================================================================', '======================================================================', '=========================', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6647, 'DNN', '1', 'GT2', ' 1', '', '', '', 'Hàng hóa ,dịch vụ bán ra', 'Sales of merchandise & service', '', '7024523122.00', '462930311.00', '0.00', '0.00', '0.00'),
(6648, 'DNN', '1a', 'GT2', ' 2', '', '', '', 'Hàng hóa ,dịch vụ không chịu thuế GTGT', 'Not VAT of merchandise & service', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6649, 'DNN', '2', 'GT2', ' 3', '', '', '', 'Hàng hóa ,dịch vụ chịu thế GTGT', 'VAT of merchandise & service', '', '7011393177.00', '345322578.00', '0.00', '0.00', '0.00'),
(6650, 'DNN', '2a', 'GT2', '', '', '', '', ' a - Hàng hóa xuất khẩu thuế suất 0%', ' a -  0%', '', '165172796.00', '0.00', '0.00', '0.00', '0.00'),
(6651, 'DNN', '2b', 'GT2', '', '', '', '', ' b - Hàng hóa ,dịch vụ thuế suất 5%', ' b -  5%', '', '6785989133.00', '339299453.00', '0.00', '0.00', '0.00'),
(6652, 'DNN', '2c', 'GT2', '', '', '', '', ' c - Hàng hóa ,dịch vụ thuế suất 10%', ' c -  10%', '', '60231248.00', '6023125.00', '0.00', '0.00', '0.00'),
(6653, 'DNN', '2d', 'GT2', '', '', '', '', ' d - Hàng hóa ,dịch vụ thuế suất 20%', ' d -  20%', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6654, 'DNN', '3', 'GT2', ' 4', '', '', '', 'Hàng hóa ,vật tư ,dịch vụ TSCĐ mua vào hoặc nhập khẩu', 'Purchase of merchandise & service', '', '16529033475.00', '1077729243.00', '0.00', '0.00', '0.00'),
(6655, 'DNN', '3', 'GT2', ' 5', '', '', '', 'Hàng hóa dịch vụ dùng cho SXKD hàng hóa ,dịch vụ', 'Merchandise & service for Work', '', '16529033475.00', '1077729243.00', '0.00', '0.00', '0.00'),
(6656, 'DNN', '', 'GT2', '', '', '', '', 'chịu thuế GTGT được tính khấu trừ thuế', 'deducted VAT', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6657, 'DNN', '7', 'GT2', ' 6', '', '', '', 'Thuế GTGT kỳ trước chuyển sang', 'Outstanding prior period of VAT', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6658, 'DNN', '7a', 'GT2', '', '', '', '', ' a - Nộp thiếu', ' a - Short', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6659, 'DNN', '7b', 'GT2', '', '', '', '', ' b - Nộp thừa hoặc chưa được khấu trừ', ' b - Over', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6660, 'DNN', '6', 'GT2', ' 7', '', '', '', 'Thuế GTGT phải nộp năm quyết toán', 'Payables of VAT in Year', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6661, 'DNN', '8', 'GT2', ' 8', '', '', '', 'Thuế GTGT đã nộp từng năm', 'Paid of VAT in Year', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6662, 'DNN', '', 'GT2', '', '', '', '', '     Trong đó :  Nộp tại các tỉnh ,thành khác', '  Include other Local', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6663, 'DNN', '9', 'GT2', ' 9', '', '', '', 'Thuế GTGT đã được hoàn trả trong năm', 'Returned of VAT in Year', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6664, 'DNN', '10', 'GT2', '10', '', '', '', 'Thuế GTGT cuối kỳ quyết toán', 'VAT closing', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6665, 'DNN', '11', 'GT2', '', '', '', '', ' + Nộp thiếu', ' a - Short', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6666, 'DNN', '12', 'GT2', '', '', '', '', ' + Nộp thừa hoặc chưa được khấu trừ', ' b - Over', 'X', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6667, 'DNN', '==', '===', '==', '', '', '', '======================================================================', '======================================================================', '=========================', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6668, 'DNN', '', 'TN1', ' 1', '', '', '', 'Doanh thu tính thuế', 'Doanh thu tính thuế', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6669, 'DNN', '', 'TN1', ' 2', '', '', '', 'Tỷ lệ thu nhập chịu thuế tính trên doanh thu  (%)', 'Tỷ lệ thu nhập chịu thuế tính trên doanh thu  (%)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6670, 'DNN', '', 'TN1', ' 3', '', '', '', 'Thu nhập chịu thuế', 'Thu nhập chịu thuế', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6671, 'DNN', '', 'TN1', ' 4', '', '', '', 'Thuế suất thuế thu nhập doanh nghiệp (%)', 'Thuế suất thuế thu nhập doanh nghiệp (%)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6672, 'DNN', '', 'TN1', ' 5', '', '', '', 'Số thuế thu nhập doanh nghiệp phải nộp', 'Số thuế thu nhập doanh nghiệp phải nộp', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6673, 'DNN', '==', '===', '==', '', '', '', '======================================================================', '======================================================================', '=========================', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6674, 'DNN', '*', 'TN2', '', '', '', '', '1. Doanh thu', '1. Doanh thu', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6675, 'DNN', '', 'TN2', '', '', '', '', ' a - Doanh thu bán hàng', ' a - Doanh thu bán hàng', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6676, 'DNN', '', 'TN2', '', '', '', '', ' b - Doanh thu bán thành phẩm', ' b - Doanh thu bán thành phẩm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6677, 'DNN', '', 'TN2', '', '', '', '', ' c - Doanh thu cung cấp dịch vụ', ' c - Doanh thu cung cấp dịch vụ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6678, 'DNN', '*', 'TN2', '', '', '', '', '2. Các khoản giãm trừ', '2. Các khoản giãm trừ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6679, 'DNN', '', 'TN2', '', '', '', '', ' a - Chiết khấu bán hàng', ' a - Chiết khấu bán hàng', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6680, 'DNN', '', 'TN2', '', '', '', '', '    - Chiết khấu hàng hóa', '    - Chiết khấu hàng hóa', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6681, 'DNN', '', 'TN2', '', '', '', '', '    - Chiết khấu thành phẩm', '    - Chiết khấu thành phẩm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6682, 'DNN', '', 'TN2', '', '', '', '', '    - Chiết khấu dịch vụ', '    - Chiết khấu dịch vụ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6683, 'DNN', '', 'TN2', '', '', '', '', ' b - Giãm giá bán hàng', ' b - Giãm giá bán hàng', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6684, 'DNN', '', 'TN2', '', '', '', '', ' c - Hàng bán bị trả lại', ' c - Hàng bán bị trả lại', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6685, 'DNN', '*', 'TN2', '', '', '', '', '3. Chi phí sản xuất kinh doanh hợp lý', '3. Chi phí sản xuất kinh doanh hợp lý', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6686, 'DNN', '', 'TN2', '', '', '', '', ' - Khấu hao Tài sản cố định', ' - Khấu hao Tài sản cố định', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6687, 'DNN', '', 'TN2', '', '', '', '', ' - Nguyên vật liệu', ' - Nguyên vật liệu', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6688, 'DNN', '', 'TN2', '', '', '', '', ' - Tiền lương', ' - Tiền lương', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6689, 'DNN', '', 'TN2', '', '', '', '', ' - Chi phí khác', ' - Chi phí khác', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6690, 'DNN', '', 'TN2', '', '', '', '', '   Trong đó :', '   Trong đó :', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6691, 'DNN', '', 'TN2', '', '', '', '', '  + Lãi tiền vay', '  + Lãi tiền vay', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6692, 'DNN', '', 'TN2', '', '', '', '', '  + Trích các khoản dự phòng', '  + Trích các khoản dự phòng', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6693, 'DNN', '', 'TN2', '', '', '', '', '  + Chi phí quảng cáo', '  + Chi phí quảng cáo', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6694, 'DNN', '', 'TN2', '', '', '', '', '  + Chi phí khác', '  + Chi phí khác', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6695, 'DNN', '*', 'TN2', '', '', '', '', '4. Tổng thu nhập từ SX ,KD (1-2-3)', '4. Tổng thu nhập từ SX ,KD (1-2-3)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6696, 'DNN', '*', 'TN2', '', '', '', '', '5. Thu nhập khác', '5. Thu nhập khác', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6697, 'DNN', '', 'TN2', '', '', '', '', ' - Chênh lệnh mua bán chứng khoán', ' - Chênh lệnh mua bán chứng khoán', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6698, 'DNN', '', 'TN2', '', '', '', '', ' - Thu nhập từ quyền sở hữu ,quyền sử dụng tài sản', ' - Thu nhập từ quyền sở hữu ,quyền sử dụng tài sản', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6699, 'DNN', '', 'TN2', '', '', '', '', ' - Thu nhập từ chuyển nhượng ,thanh lý tài sản', ' - Thu nhập từ chuyển nhượng ,thanh lý tài sản', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6700, 'DNN', '', 'TN2', '', '', '', '', ' - Lãi tiền gửi ,lãi cho vay vốn ,lãi bán hàng trả chậm', ' - Lãi tiền gửi ,lãi cho vay vốn ,lãi bán hàng trả chậm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6701, 'DNN', '', 'TN2', '', '', '', '', ' - Chênh lệch do bán ngoại tệ', ' - Chênh lệch do bán ngoại tệ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6702, 'DNN', '', 'TN2', '', '', '', '', ' - Kết dư các khoản trích trước chi không hết ,các khoản dự phòng', ' - Kết dư các khoản trích trước chi không hết ,các khoản dự phòng', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6703, 'DNN', '', 'TN2', '', '', '', '', ' - Thu về tiền phạt vi phạm hợp đồng kinh tế', ' - Thu về tiền phạt vi phạm hợp đồng kinh tế', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6704, 'DNN', '', 'TN2', '', '', '', '', ' - Thu các khoản thu khó đòi nay đòi được', ' - Thu các khoản thu khó đòi nay đòi được', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6705, 'DNN', '', 'TN2', '', '', '', '', ' - Thu các khoản nợ phải trả không còn chủ', ' - Thu các khoản nợ phải trả không còn chủ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6706, 'DNN', '', 'TN2', '', '', '', '', ' - Các khoản thu nhập bỏ sót từ những năm trước', ' - Các khoản thu nhập bỏ sót từ những năm trước', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6707, 'DNN', '', 'TN2', '', '', '', '', ' - Các khoản thu nhập nhận được từ nước ngoài', ' - Các khoản thu nhập nhận được từ nước ngoài', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6708, 'DNN', '', 'TN2', '', '', '', '', ' - Các khoản thu nhập không tính vào doanh thu', ' - Các khoản thu nhập không tính vào doanh thu', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6709, 'DNN', '', 'TN2', '', '', '', '', ' - Các khoản thu nhập khác', ' - Các khoản thu nhập khác', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6710, 'DNN', '*', 'TN2', '', '', '', '', '6. Lỗ năm trước chuyển sang', '6. Lỗ năm trước chuyển sang', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6711, 'DNN', '*', 'TN2', '', '', '', '', '7. Tổng thu nhập chịu thuế (4+5+6)', '7. Tổng thu nhập chịu thuế (4+5+6)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6712, 'DNN', '*', 'TN2', '', '', '', '', '8. Thu nhập chịu thuế thu nhập bổ sung', '8. Thu nhập chịu thuế thu nhập bổ sung', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6713, 'DNN', '', 'TN2', '', '', '', '', '  Trong đó :', '  Trong đó :', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6714, 'DNN', '', 'TN2', '', '', '', '', '   Thu nhập từ góp vốn cổ phần ,liên doanh ,liên kết kinh tế', '   Thu nhập từ góp vốn cổ phần ,liên doanh ,liên kết kinh tế', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6715, 'DNN', '==', '===', '==', '', '', '', '======================================================================', '======================================================================', '=========================', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6716, 'DNN', '', 'TN3', '', '', '', '', '1. Tổng doanh thu tính thu nhập chịu thuế', '1. Tổng doanh thu tính thu nhập chịu thuế', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6717, 'DNN', '', 'TN3', '', '', '', '', '2. Chi phí sản xuất kinh doanh hợp lý', '2. Chi phí sản xuất kinh doanh hợp lý', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6718, 'DNN', '', 'TN3', '', '', '', '', '3. Thu nhập từ hoạt động sản xuất kinh doanh (1-2)', '3. Thu nhập từ hoạt động sản xuất kinh doanh (1-2)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6719, 'DNN', '', 'TN3', '', '', '', '', '4. Thu nhập khác', '4. Thu nhập khác', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6720, 'DNN', '', 'TN3', '', '', '', '', '5. Lỗ năm trước chuyển sang', '5. Lỗ năm trước chuyển sang', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6721, 'DNN', '', 'TN3', '', '', '', '', '6. Tổng thu nhập chịu thuế (3+4-5)', '6. Tổng thu nhập chịu thuế (3+4-5)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6722, 'DNN', '', 'TN3', '', '', '', '', '7. Thuế suất', '7. Thuế suất', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6723, 'DNN', '', 'TN3', '', '', '', '', '8. Thuế thu nhập (6x7)', '8. Thuế thu nhập (6x7)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6724, 'DNN', '', 'TN3', '', '', '', '', '9. Thu nhập tính thuế bổ sung', '9. Thu nhập tính thuế bổ sung', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6725, 'DNN', '', 'TN3', '', '', '', '', '10. Thuế suất bổ sung', '10. Thuế suất bổ sung', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6726, 'DNN', '', 'TN3', '', '', '', '', '11. Thuế thu nhập bổ sung', '11. Thuế thu nhập bổ sung', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6727, 'DNN', '', 'TN3', '', '', '', '', '12. Tổng thuế thu nhập phải nộp (8+11)', '12. Tổng thuế thu nhập phải nộp (8+11)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6728, 'DNN', '', 'TN3', '', '', '', '', '13. Thanh toán thuế', '13. Thanh toán thuế', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6729, 'DNN', '', 'TN3', '', '', '', '', ' - Năm trước chuyển sang [ Nộp thiếu (+) ,nộp thừa (-) ]', ' - Năm trước chuyển sang [ Nộp thiếu (+) ,nộp thừa (-) ]', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6730, 'DNN', '', 'TN3', '', '', '', '', ' - Phải nộp năm nay', ' - Phải nộp năm nay', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6731, 'DNN', '', 'TN3', '', '', '', '', ' - Đã tạm nộp trong năm', ' - Đã tạm nộp trong năm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6732, 'DNN', '', 'TN3', '', '', '', '', ' - Trừ thuế đã nộp ở nước ngoài', ' - Trừ thuế đã nộp ở nước ngoài', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6733, 'DNN', '', 'TN3', '', '', '', '', ' - Số còn phải nộp', ' - Số còn phải nộp', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6734, 'DNN', '==', '===', '==', '', '', '', '======================================================================', '======================================================================', '=========================', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6735, 'DNN', '', 'TN4', '', '', '', '', ' 1.Vốn cố định', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6736, 'DNN', '', 'TN4', '', '', '', '', '    a. Vốn cố định tính thu', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6737, 'DNN', '', 'TN4', '', '', '', '', ' 2.Vốn lưu động', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6738, 'DNN', '', 'TN4', '', '', '', '', '    a. Vốn lưu động tính thu', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6739, 'DNN', '', 'TN4', '', '', '', '', ' 3.Vốn tăng giãm trong kỳ', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6740, 'DNN', '', 'TN4', '', '', '', '', '    Trong đó : Vốn ngân sách', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6741, 'DNN', '', 'TN4', '', '', '', '', '    a. Vốn cố định tăng (+) giãm (-)', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6742, 'DNN', '', 'TN4', '', '', '', '', '    b. Vốn lưu động tăng (+) giãm (-)', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6743, 'DNN', '', 'TN4', '', '', '', '', ' 4.Tính thu sử dụng vốn cuối kỳ ( 1a+2a+3a+3b)', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6744, 'DNN', '', 'TN4', '', '', '', '', ' 5.Góp vốn liên doanh', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6745, 'DNN', '', 'TN4', '', '', '', '', '    a. Góp vốn giá trị Quyền sử dụng đất', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6746, 'DNN', '', 'TN4', '', '', '', '', ' 6.Tổng số vốn phải thu tính sử dụng vốn ( 4+5-5a)', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6747, 'DNN', '', 'TN4', '', '', '', '', ' 7.Tỉ lệ thu trên vốn  x  mức vốn tính thu', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6748, 'DNN', '', 'TN4', '', '', '', '', '    a. Tỉ lệ  ... x', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6749, 'DNN', '', 'TN4', '', '', '', '', '    b. Tỉ lệ  ... x', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6750, 'DNN', '', 'TN4', '', '', '', '', ' 8.Quan hệ nộp NS về sử dụng vốn', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6751, 'DNN', '', 'TN4', '', '', '', '', '    a. Số kỳ trước chuyển sang', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6752, 'DNN', '', 'TN4', '', '', '', '', '         + Trong đó thu SDV liên doanh', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6753, 'DNN', '', 'TN4', '', '', '', '', '    b. Số phát sinh phân bổ trong năm', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6754, 'DNN', '', 'TN4', '', '', '', '', '         + Trong đó thu SDV liên doanh', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6755, 'DNN', '', 'TN4', '', '', '', '', ' 9.Tỉ lệ phân bổ ( 4 ---> quý ; 12 --->tháng )', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6756, 'DNN', '', 'TN4', '', '', '', '', ' 10.Tổng số phải thu sử dụng vốn trong kỳ (8b/9)', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6757, 'DNN', '==', '===', '==', '', '', '', '======================================================================', '======================================================================', '=========================', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6758, 'DNN', '02', 'KQ*', '01', '', '', 'IV.08', '1. Doanh thu bán hàng và cung cấp dịch vụ', 'Revenues and  service', '511,512/52,53,333,91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6759, 'DNN', '02', 'KQ*', '02', '', '', '', '2. Các khoản giảm trừ doanh thu', 'Deductions ( 03 = 04 + 05 + 06 + 07 )', 'Z( 04+05+06+07)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6760, 'DNN', '02', 'KQ_', '04', '', '', '', '   - Chiết khấu thương mại', ' - Sales discounts', '511,512/521', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6761, 'DNN', '02', 'KQ_', '05', '', '', '', '   - Giảm giá hàng bán', ' - Sales allowances', '511,512/532', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6762, 'DNN', '02', 'KQ_', '06', '', '', '', '   - Hàng bán bị trả lại', ' - Sales returns', '511,512/531', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6763, 'DNN', '02', 'KQ_', '07', '', '', '', '   - Thuế tiêu thụ đặc biệt , thuế xuất khẩu ,Thuế GTGT', ' - Excise tax ,export tax ,VAT tax', '511,512/3331,3332,3333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6764, 'DNN', '02', 'KQ_', '', '', '', '', '      Theo phương pháp trực tiếp phải nộp', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6765, 'DNN', '02', 'KQ', '10', '', '', '', '3. Doanh thu thuần về bán hàng và cung cấp DV (10 = 01-02)', '1.Net income ( 10 = 01 - 02 )', 'Z(01-02)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6766, 'DNN', '02', 'KQ', '11', '', '', '', '4. Giá vốn hàng bán', '2.Original rate of sold goods', '91/632', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6767, 'DNN', '02', 'KQ*', '20', '', '', '', '5. Lợi nhuận gộp về bán hàng và cung cấp DV  ( 20 = 10 -11)', '3.Gross profit  ( 20 = 10 -11)', 'Z(10-11)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6768, 'DNN', '02', 'KQ', '21', '', '', '', '6. Doanh thu hoạt động tài chính', '4.Financial income', '515/91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6769, 'DNN', '02', 'KQ', '22', '', '', '', '7. Chi phí tài chính', '5.Financial expenses', '91/635', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6770, 'DNN', '02', 'KQ', '23', '', '', '', '    Trong đó : Chi phí lãi vay', '   Include : Profits of borrowings', '91/6351', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6771, 'DNN', '02', 'KQ', '24', '', '', '', '8. Chi phí quản lý doanh nghiệp', '7.Enteprise management costs', '91/642,641,142', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6772, 'DNN', '02', 'KQ*', '30', '', '', '', '9. Lợi nhuận thuần từ hoạt động kinh doanh', '8.Net profit from business', 'Z(20+21-22-24)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6773, 'DNN', '02', 'KQ', '', '', '', '', '     [ 30 = 20 + 21 - 22- 24  ]', '     [ 30 = 20 + (21-22) - (24+25)  ]', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6774, 'DNN', '02', 'KQ', '31', '', '', '', '10. Thu nhập khác', '9.Other Income', '721,711/91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6775, 'DNN', '02', 'KQ', '32', '', '', '', '11. Chi phí khác', '10.Other expenses', '91/811', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6776, 'DNN', '02', 'KQ*', '40', '', '', '', '12. Lợi nhuận khác', '11.Other Profit', 'Z(31-32)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6777, 'DNN', '02', 'KQ', '41', '', '', '', '     ( 40 = 31 - 32 )', '     ( 40 = 31 - 32 )', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6778, 'DNN', '02', 'KQ*', '50', '', '', 'IV.09', '13. Tổng lợi nhuận trước thuế ( 50 = 30 + 40 )', '12.Gross profit before tax (30+40+50)', 'Z(30+40)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6779, 'DNN', '02', 'KQ', '51', '', '', '', '14. Chi phí thuế thu nhập doanh nghiệp', '13.Payable profit tax', '91/821', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6780, 'DNN', '02', 'KQ*', '60', '', '', '', '15. Lợi nhuận sau thuế thu nhập doanh nghiệp ( 60 = 50 - 51 )', '14.Profit after tax (60-70)', 'Z(50-51-52)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6781, 'DNN', '02', 'NS*', '10', '', '', '', 'I - Thuế', 'I - Taxes', '/333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6782, 'DNN', '02', 'NS', '11', '', '', '', '1. Thuế giá trị gia tăng hàng bán nội địa', '1.Turnover tax (or VAT)', '/33311', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6783, 'DNN', '02', 'NS', '12', '', '', '', '2. Thuế GTGT hàng nhập khẩu', '2.Turnover tax (or VAT)', '/33312', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6784, 'DNN', '02', 'NS', '13', '', '', '', '3. Thuế tiêu thụ đặc biệt', '3.Excise tax', '/3332', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6785, 'DNN', '02', 'NS', '14', '', '', '', '4. Thuế xuất ,nhập khẩu', '4.Import and export duties', '/3333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6786, 'DNN', '02', 'NS', '15', '', '', '', '5. Thuế thu nhập doanh nghiệp', '5.Profit tax', '/3334', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6787, 'DNN', '02', 'NS', '16', '', '', '', '6. Thu trên vốn', '6.Capital earnings', '/3335', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6788, 'DNN', '02', 'NS', '17', '', '', '', '7. Thuế tài nguyên', '7.Land and house tax', '/3336', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6789, 'DNN', '02', 'NS', '18', '', '', '', '8. Thuế nhà đất   (33371)', '8.Land lease costs', '/33371', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6790, 'DNN', '02', 'NS', '19', '', '', '', '9. Tiền thuê đất    (33372)', '9.Land lease costs', '/33372', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6791, 'DNN', '02', 'NS', '20', '', '', '', '10. Các loại thuế khác', '10.Others', '/3338', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6792, 'DNN', '02', 'NS', '', '', '', '', '', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6793, 'DNN', '02', 'NS*', '30', '', '', '', 'II - Các khoản phải nộp khác', 'III - OTHER PAYMENTS', '/3339', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6794, 'DNN', '02', 'NS', '31', '', '', '', '1. Các khoản phụ thu                       (33391)', '1.Extra collections', '/33391', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6795, 'DNN', '02', 'NS', '32', '', '', '', '2. Các khoản phí ,lệ phí                   (33392)', '2.Fees and charges', '/33392', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6796, 'DNN', '02', 'NS', '33', '', '', '', '3. Các khoản phải nộp khác             (33393)', '3.Others', '/33393', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6797, 'DNN', '02', 'GT*', '', '', '', '', 'I - Thuế giá trị gia tăng được khấu trừ', 'I - Thuế giá trị gia tăng được khấu trừ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6798, 'DNN', '02', 'GT/', '10', '', '', '', ' 1.Số thuế GTGT còn được khấu trừ ,hoàn lại đầu kỳ', ' 1.Số thuế GTGT còn được khấu trừ ,hoàn lại đầu kỳ', 'DK-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6799, 'DNN', '02', 'GT', '11', '', '', '', ' 2.Số thuế GTGT được khấu trừ phát sinh', ' 2.Số thuế GTGT được khấu trừ phát sinh', 'NO-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6800, 'DNN', '02', 'GT', '12', '', '', '', ' 3.Số thuế GTGT đã được khấu trừ ,đã hoàn lại ,thuế GTGT', ' 3.Số thuế GTGT đã được khấu trừ ,đã hoàn lại ,thuế GTGT', 'CO-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6801, 'DNN', '02', 'GT', '', '', '', '', '    hàng mua trả lại và không được khấu trừ  ( 12 = 13 + 14 +15 )', '    hàng mua trả lại và không được khấu trừ  ( 12 = 13 + 14 +15 )', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6802, 'DNN', '02', 'GT', '', '', '', '', '    Trong đó :', '    Trong đó :', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6803, 'DNN', '02', 'GT', '13', '', '', '', ' a.Số thuế giá trị gia tăng đã khấu trừ', ' a.Số thuế giá trị gia tăng đã khấu trừ', '3331/133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6804, 'DNN', '02', 'GT', '14', '', '', '', ' b.Số thuế giá trị gia tăng đã hoàn lại', ' b.Số thuế giá trị gia tăng đã hoàn lại', '133/133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6805, 'DNN', '02', 'GT', '15', '', '', '', ' c.Số thuế giá trị gia tăng hàng mua trả lại ,giãm giá hàng mua', ' c.Số thuế giá trị gia tăng hàng mua trả lại ,giãm giá hàng mua', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6806, 'DNN', '02', 'GT', '16', '', '', '', ' d.Số thuế giá trị gia tăng không được khấu trừ', ' c.Số thuế giá trị gia tăng không được khấu trừ', '142/133,632/133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6807, 'DNN', '02', 'GT/', '17', '', '', '', ' 4.Số thuế GTGT còn được khấu trừ ,hoàn lại', ' 4.Số thuế GTGT còn được khấu trừ ,hoàn lại', 'CK-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6808, 'DNN', '02', 'GT', '', '', '', '', '    cuối kỳ  ( 16 = 10+11-12)', '    cuối kỳ  ( 16 = 10+11-12)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6809, 'DNN', '02', 'GT*', '', '', '', '', 'II - Thuế giá trị gia tăng được hoàn lại', 'II - Thuế giá trị gia tăng được hoàn lại', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6810, 'DNN', '02', 'GT/', '20', '', '', '', ' 1. Thuế giá trị gia tăng còn được hoàn lại đầu kỳ', ' 1. Thuế giá trị gia tăng còn được hoàn lại đầu kỳ', 'DK-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6811, 'DNN', '02', 'GT', '21', '', '', '', ' 2. Thuế giá trị gia tăng được hoàn lại phát sinh', ' 2. Thuế giá trị gia tăng được hoàn lại', 'NO-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6812, 'DNN', '02', 'GT', '22', '', '', '', ' 3. Thuế giá trị gia tăng đã hoàn lại', ' 3. Thuế giá trị gia tăng đã hoàn lại', 'CO-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6813, 'DNN', '02', 'GT/', '23', '', '', '', ' 4. Thuế GTGT còn được hoàn lại cuối kỳ cuối kỳ  ( 23 = 20 + 21 - 22)', ' 4. Thuế GTGT còn được hoàn lại cuối kỳ cuối kỳ  ( 23 = 20 + 21 - 22)', 'CK-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6814, 'DNN', '02', 'GT*', '', '', '', '', 'III - Thuế giá trị gia tăng được giảm', 'III - Thuế giá trị gia tăng được miển giãm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6815, 'DNN', '02', 'GT/', '30', '', '', '', ' 1. Thuế giá trị gia tăng còn được giãm đầu kỳ', ' 1. Thuế giá trị gia tăng còn được miển giãm đầu kỳ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6816, 'DNN', '02', 'GT', '31', '', '', '', ' 2. Thuế giá trị gia tăng được giảm phát sinh', ' 2. Thuế giá trị gia tăng được miển giãm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6817, 'DNN', '02', 'GT', '32', '', '', '', ' 3. Thuế giá trị gia tăng đã được giảm', ' 3. Thuế giá trị gia tăng đã được miển giãm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6818, 'DNN', '02', 'GT/', '33', '', '', '', ' 4. Thuế GTGTcòn được giãm cuối kỳ  ( 33 = 30 + 31 - 32)', ' 4. Thuế GTGTcòn được giãm cuối kỳ  ( 33 = 30 + 31 - 32)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6819, 'DNN', '02', 'GT*', '', '', '', '', 'IV - Thuế giá trị gia tăng hàng bán nội địa', 'IV - Thuế giá trị gia tăng hàng bán nội địa', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6820, 'DNN', '02', 'GT/', '40', '', '', '', ' 1.Thuế giá trị gia tăng đầu ra còn phải nộp đầu kỳ', ' 1.Thuế giá trị gia tăng đầu ra còn phải nộp đầu kỳ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6821, 'DNN', '02', 'GT', '41', '', '', '', ' 2.Thuế giá trị gia tăng đầu ra phát sinh', ' 2.Thuế giá trị gia tăng đầu ra phát sinh', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6822, 'DNN', '02', 'GT', '42', '', '', '', ' 3.Thuế giá trị gia tăng đầu vào đã khấu trừ', ' 3.Thuế giá trị gia tăng đầu vào đã khấu trừ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6823, 'DNN', '02', 'GT', '43', '', '', '', ' 4.Thuế giá trị gia tăng hàng bán bị trả lại ,bị giảm giá', ' 4.Thuế giá trị gia tăng hàng bán bị trả lại ,bị giảm giá', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6824, 'DNN', '02', 'GT', '44', '', '', '', ' 5.Thuế giá trị gia tăng được giảm trừ vào số thuế phải nộp', ' 5.Thuế giá trị gia tăng được giảm trừ vào số thuế phải nộp', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6825, 'DNN', '02', 'GT', '45', '', '', '', ' 6.Thuế giá trị gia tăng hàng bán nội địa đã nộp vào NSNN', ' 6.Thuế giá trị gia tăng hàng bán nội địa đã nộp vào NSNN', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6826, 'DNN', '02', 'GT/', '46', '', '', '', ' 7.Thuế giá trị gia tăng hàng bán nội địa còn phải nộp cuối kỳ', ' 7.Thuế giá trị gia tăng hàng bán nội địa còn phải nộp cuối kỳ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6827, 'DNN', '02', 'GT', '', '', '', '', '     ( 46 = 40+41-42-43-44-45 )', '     ( 46 = 40+41-42-43-44-45 )', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6828, 'DNN', '05', 'CB*', '', '', '', '', 'A. Tình hình tài chính', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6829, 'DNN', '05', 'CB*', '', '', '', '', 'I. Tài sản ngắn hạn', '', '1-16-129-159-1319-1399-13619-13689-1389,331,333,337,338-3389', '26192923549.00', '26281157481.00', '0.00', '0.00', '0.00'),
(6830, 'DNN', '05', 'CB', '', '', '', '', '1. Các khoản phải thu', '', '14-142,13-1319-13619-13689-1389-1399,331,337,338-3389', '23871817452.00', '25008614125.00', '0.00', '0.00', '0.00'),
(6831, 'DNN', '05', 'CB', '', '', '', '', '2. Hàng tồn kho', '', '15-159', '1827995279.00', '456275874.00', '0.00', '0.00', '0.00'),
(6832, 'DNN', '05', 'CB', '', '', '', '', '3. Tài sản ngắn hạn khác', '', '142,133,333', '170662097.00', '219741340.00', '0.00', '0.00', '0.00'),
(6833, 'DNN', '05', 'CB*', '', '', '', '', 'II. Tài sản dài hạn', '', '1319,13619,13689,1389,3389,1399,2-214-229', '1255802515.00', '1110321899.00', '0.00', '0.00', '0.00'),
(6834, 'DNN', '05', 'CB', '', '', '', '', '1. Các khoản phải thu dài hạn', '', '1319,13619,13689,1389,3389,244,1399', '-13746812.00', '-13582812.00', '0.00', '0.00', '0.00'),
(6835, 'DNN', '05', 'CB', '', '', '', '', '2. Tài sản cố định', '', '21-214,241', '1259549327.00', '1122588711.00', '0.00', '0.00', '0.00'),
(6836, 'DNN', '05', 'CB', '', '', '', '', '   - Nguyên giá', '', '21', '2481518466.00', '1842610273.00', '0.00', '0.00', '0.00'),
(6837, 'DNN', '05', 'CB', '', '', '', '', '   - Giá trị hao mòn lũy kế', '', '214', '-1516712387.00', '-1022764810.00', '0.00', '0.00', '0.00'),
(6838, 'DNN', '05', 'CB', '', '', '', '', '   - Chi phí xây dựng cơ bản dở dang', '', '241', '294743248.00', '302743248.00', '0.00', '0.00', '0.00'),
(6839, 'DNN', '05', 'CB', '', '', '', '', '3. Các khoản đầu tư tài chính dài hạn', '', '22-229', '10000000.00', '216000.00', '0.00', '0.00', '0.00'),
(6840, 'DNN', '05', 'CB', '', '', '', '01', ' - Đầu tư vào công ty con', '', '221', '10000000.00', '0.00', '0.00', '0.00', '0.00'),
(6841, 'DNN', '05', 'CB', '', '', '', '01', ' - Dự phòng giảm giá chứng khoán đầu tư dài hạn', '', '229', '0.00', '-229000.00', '0.00', '0.00', '0.00'),
(6842, 'DNN', '05', 'CB', '', '', '', '', '4. Tài sản dài hạn khác', '', '242', '0.00', '1100000.00', '0.00', '0.00', '0.00'),
(6843, 'DNN', '05', 'CB*', '', '', '', '', 'III. Nợ phải trả', '', '3,13-139,14,138,451,344', '26360678813.00', '26092557361.00', '0.00', '0.00', '0.00'),
(6844, 'DNN', '05', 'CB*', '', '', '', '', '1. Nợ ngắn hạn', '', '31,33-3319-3369,13-139-1369,14,138-1389,451,344', '26360678813.00', '26080845361.00', '0.00', '0.00', '0.00'),
(6845, 'DNN', '05', 'CB', '', '', '', '', '2. Nợ dài hạn', '', '1389,3319,3369,1369,34-344', '0.00', '1369000.00', '0.00', '0.00', '0.00'),
(6846, 'DNN', '05', 'CB*', '', '', '', '', 'IV. Vốn chủ sở hữu', '', '4-451,412,413,421,431,461', '3785462924.00', '3867850519.00', '0.00', '0.00', '0.00'),
(6847, 'DNN', '05', 'CB', '', 'ZV', '', '', '1.Vốn đầu tư của chủ sở hữu', '', '4111', '2771098563.00', '2771098563.00', '0.00', '0.00', '0.00'),
(6848, 'DNN', '05', 'CB', '', '', '', '', '2.Quỹ đầu tư phát triển', '', '414', '195602574.00', '195602574.00', '0.00', '0.00', '0.00'),
(6849, 'DNN', '05', 'CB', '', '', '', '', '3. Quỹ dự phòng tài chính', '', '415', '50479823.00', '51256823.00', '0.00', '0.00', '0.00'),
(6850, 'DNN', '05', 'CB', '', '', '', '', '4. Lợi nhuận chưa phân phối', '', '421', '0.00', '74891595.00', '0.00', '0.00', '0.00'),
(6851, 'DNN', '05', 'CB', '', '', '', '', '5. Quỹ khen thưởng, phúc lợi', '', '431', '1065151.00', '1065151.00', '0.00', '0.00', '0.00'),
(6852, 'DNN', '05', 'CB', '', '', '', '', '   - Tăng trong năm', '', 'CO431', '5243849.00', '0.00', '0.00', '0.00', '0.00'),
(6853, 'DNN', '05', 'CB', '', '', '', '', '   - Giảm trong năm', '', 'NO431', '27213449.00', '8919000.00', '0.00', '0.00', '0.00'),
(6854, 'DNN', '05', 'CB*', '', '', '', '', 'B/ Kết quả kinh doanh', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6855, 'DNN', '05', 'CB', '', 'ZD', '', '', '1.Tổng doanh thu', '', 'DT911', '38674630364.00', '27894073016.00', '0.00', '0.00', '0.00'),
(6856, 'DNN', '05', 'CB', '', '', '', '', '2.Tổng lãi (+), Lỗ (-)', '', 'LAI421', '-138971173.00', '213862768.00', '0.00', '0.00', '0.00'),
(6857, 'DNN', '05', 'CB', '', '', '', '', '   Trong đó : Lãi từ hoạt động đầu tư tài chính', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6858, 'DNN', '05', 'CB', '', '', '', '', '3.Tổng lợi nhuận sau thuế TNDN', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6859, 'DNN', '05', 'CB', '', '', '', '', '4.Tổng phải nộp ngân sách trong năm', '', 'CO333', '2326041442.00', '2101402961.00', '0.00', '0.00', '0.00'),
(6860, 'DNN', '05', 'CB*', '', '', '', '', 'C/ Các chỉ tiêu đánh giá khác', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6861, 'DNN', '05', 'CB', '', 'TS', 'ZD', '', '1. Tỷ suất lợi nhuận/doanh thu', '', 'LAI421', '0.00', '0.01', '0.00', '0.00', '0.00'),
(6862, 'DNN', '05', 'CB', '', 'TS', 'ZV', '', '2. Lợi nhuận/Vốn đầu tư của chủ sở hữu', '', 'LAI421', '-0.05', '0.08', '0.00', '0.00', '0.00'),
(6863, 'DNN', '05', 'CB', '', 'TS', 'ZV', '', '3.Tổng nợ phải trả/Vốn đầu tư của chủ sở hữu', '', '3,13-139,14,138,451,344', '9.51', '9.42', '0.00', '0.00', '0.00'),
(6864, 'DNN', '05', 'CB', '', '', '', '', '4.Tổng quỹ lương', '', 'CO334', '6537022377.00', '4825979110.00', '0.00', '0.00', '0.00'),
(6865, 'DNN', '05', 'CB', '', '', '', '', '5.Số lao động bình quân trong năm', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6866, 'DNN', '05', 'CB', '', '', '', '01', '6.Tiền lương bình quân', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6867, 'DNN', '05', 'CB', '', '', '', '01', '7.Xếp loại doanh nghiệp', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6868, 'DNN', '05', 'CB', '', '', '', '02', '6.Lợi nhuận được chia từ vốn nhà nước tại Công ty', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6869, 'DNN', '15', 'KQ*', '01', '01', '', 'VI.01', '1. Doanh thu bán hàng và cung cấp dịch vụ', '1. Gross sales', '511,512/52,53,333,91', '24124.00', '242142.00', '0.00', '0.00', '0.00'),
(6870, 'DNN', '15', 'KQ', '01a', '', '', '', '   -  Doanh thu bán hàng hóa ( 5111)', '', '5111,512/52,53,333,91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6871, 'DNN', '15', 'KQ', '01b', '', '', '', '   -  Doanh thu bán các thành phẩm ( 5112)', '', '5112,512/52,53,333,91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6872, 'DNN', '15', 'KQ', '01c', '', '', '', '   -  Doanh thu cung cấp dịch vụ ( 5113)', '', '5113,512/52,53,333,91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6873, 'DNN', '15', 'KQ', '01d', '', '', '', '   -  Doanh thu khác ( 5114,5117,5118)', '', '5114,5115,5116,5117,5118,512/52,53,333,91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6874, 'DNN', '15', 'KQ*', '02', '03', '', 'VI.02', '2. Các khoản giảm trừ doanh thu', '2. Less', '511,512/521,531,532,3331,3332,3333', '33.00', '33.00', '0.00', '0.00', '0.00'),
(6875, 'DNN', '15', 'KQ', '02a', '04', '', '', '   -  Chiết khấu thương mại ( 5211)', '', '511,512/5211,531,532,3331,3332,3333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6876, 'DNN', '15', 'KQ', '02b', '05', '', '', '   -  Giảm giá hàng bán ( 5212)', '', '511,512/5212,531,532,3331,3332,3333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6877, 'DNN', '15', 'KQ', '02c', '06', '', '', '   -  Hàng bán bị trả lại ( 5213)', '', '511,512/5213,531,532,3331,3332,3333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6878, 'DNN', '15', 'KQ', '10', '', '', '', '3. Doanh thu thuần về bán hàng và cung cấp DV (10 = 01-02)', '3. Net sales ( 10 = 01 - 02 )', 'Z(01-02)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6879, 'DNN', '15', 'KQ*', '11', '10', '', 'VI.03', '4. Giá vốn hàng bán', '4. Cost of goods sold', '91/632', '4342.00', '32432.00', '0.00', '0.00', '0.00'),
(6880, 'DNN', '15', 'KQ', '11a', '', '', '', '   -  Giá vốn của hàng hóa đã bán ( 6321)', '', '91/6321', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6881, 'DNN', '15', 'KQ', '11b', '', '', '', '   -  Giá vốn của thành phẩm đã bán ( 6322)', '', '91/6322', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6882, 'DNN', '15', 'KQ', '11c', '', '', '', '   -  Giá vốn của dịch vụ đã cung cấp ( 6323)', '', '91/6323', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6883, 'DNN', '15', 'KQ', '11d', '', '', '', '   -  Giá vốn khác ( 6324)', '', '91/6324', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6884, 'DNN', '15', 'KQ', '11e', '', '', '', '   -  Các khoản chi phí khác được tính vào giá vốn ( 6325)', '', '91/6325', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6885, 'DNN', '15', 'KQ', '11f', '', '', '', '   -  Các khoản ghi giảm giá vốn hàng bán', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6886, 'DNN', '15', 'KQ', '20', '', '', '', '5. Lợi nhuận gộp về bán hàng và cung cấp DV  ( 20 = 10 -11)', '5. Gross profit ( 20 = 10 -11)', 'Z(10-11)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6887, 'DNN', '15', 'KQ', '21', '08', '', 'VI.04', '6. Doanh thu hoạt động tài chính', '6. Income from financial activities', '515/91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6888, 'DNN', '15', 'KQ', '22', '13', '', 'VI.05', '7. Chi phí tài chính', '7. Expenses from financial activities', '91/635', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6889, 'DNN', '15', 'KQ', '23', '14', '', '', '    Trong đó : Chi phí lãi vay', '    Of witch: Interest payment', '91/6351', '0.00', '0.00', '0.00', '0.00', '0.00');
INSERT INTO `ketquakd` (`id`, `chedokt`, `kyhieu`, `swt`, `maso`, `kyhieu1`, `kyhieu2`, `tminh`, `chitieu`, `chitieuu`, `cachtinh`, `kytruoc`, `kynay`, `luyke`, `luykeno`, `luykeco`) VALUES
(6890, 'DNN', '15', 'KQ', '24', '12', '', 'VI.06', '8. Chi phí quản lý kinh doanh', '9. General and administration expenses', '91/641,642,142', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6891, 'DNN', '15', 'KQ', '30', '15', '', '', '9. Lợi nhuận thuần từ hoạt động kinh doanh  [ 30 = 20 + 21-22- 24 ]', '10. Operating profit', 'Z(20+21-22-24)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6892, 'DNN', '15', 'KQ', '31', '16', '', 'VI.07', '10. Thu nhập khác', '11. Other income', '721,711/91', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6893, 'DNN', '15', 'KQ', '32', '17', '', 'VI.08', '11. Chi phí khác', '12. Other expenses', '91/811', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6894, 'DNN', '15', 'KQ', '40', '18', '', '', '12. Lợi nhuận khác  ( 40 = 31 - 32 )', '13. Other profit/loss  ( 40 = 31 - 32 )', 'Z(31-32)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6895, 'DNN', '15', 'KQ', '50', '19', '', '', '13. Tổng lợi nhuận Kế toán trước thuế ( 50 = 30 + 40 )', '14. Profit before tax/ loss ( 50 = 30 + 40 )', 'Z(30+40)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6896, 'DNN', '15', 'KQ', '51', '', '', 'VI.09', '14. Chi phí thuế thu nhập doanh nghiệp', '16. Deferred income tax liabilities', '91/821', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6897, 'DNN', '15', 'KQ', '60', '', '', '', '15. Lợi nhuận sau thuế thu nhập doanh nghiệp  [ 60 = 50 - 51 ]', '17. Net profit after tax/ loss ( 60 = 50 - 51)', 'Z(50-51)', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6898, 'DNN', '15', 'NS*', '10', '', '', '', 'I - Thuế', 'I - Taxes', '/333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6899, 'DNN', '15', 'NS', '11', '', '', '', '1. Thuế giá trị gia tăng hàng bán nội địa', '1.Turnover tax (or VAT)', '/33311', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6900, 'DNN', '15', 'NS', '12', '', '', '', '2. Thuế GTGT hàng nhập khẩu', '2.Turnover tax (or VAT)', '/33312', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6901, 'DNN', '15', 'NS', '13', '', '', '', '3. Thuế tiêu thụ đặc biệt', '3.Excise tax', '/3332', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6902, 'DNN', '15', 'NS', '14', '', '', '', '4. Thuế xuất ,nhập khẩu', '4.Import and export duties', '/3333', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6903, 'DNN', '15', 'NS', '15', '', '', '', '5. Thuế thu nhập doanh nghiệp', '5.Profit tax', '/3334', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6904, 'DNN', '15', 'NS', '16', '', '', '', '6. Thu trên vốn', '6.Capital earnings', '/3335', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6905, 'DNN', '15', 'NS', '17', '', '', '', '7. Thuế tài nguyên', '7.Land and house tax', '/3336', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6906, 'DNN', '15', 'NS', '18', '', '', '', '8. Thuế nhà đất   (33371)', '8.Land lease costs', '/33371', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6907, 'DNN', '15', 'NS', '19', '', '', '', '9. Tiền thuê đất    (33372)', '9.Land lease costs', '/33372', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6908, 'DNN', '15', 'NS', '20', '', '', '', '10. Các loại thuế khác', '10.Others', '/3338', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6909, 'DNN', '15', 'NS', '', '', '', '', '', '', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6910, 'DNN', '15', 'NS*', '30', '', '', '', 'II - Các khoản phải nộp khác', 'III - OTHER PAYMENTS', '/3339', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6911, 'DNN', '15', 'NS', '31', '', '', '', '1. Các khoản phụ thu                       (33391)', '1.Extra collections', '/33391', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6912, 'DNN', '15', 'NS', '32', '', '', '', '2. Các khoản phí ,lệ phí                   (33392)', '2.Fees and charges', '/33392', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6913, 'DNN', '15', 'NS', '33', '', '', '', '3. Các khoản phải nộp khác             (33393)', '3.Others', '/33393', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6914, 'DNN', '15', 'GT*', '', '', '', '', 'I - Thuế giá trị gia tăng được khấu trừ', 'I - Thuế giá trị gia tăng được khấu trừ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6915, 'DNN', '15', 'GT/', '10', '', '', '', ' 1.Số thuế GTGT còn được khấu trừ ,hoàn lại đầu kỳ', ' 1.Số thuế GTGT còn được khấu trừ ,hoàn lại đầu kỳ', 'DK-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6916, 'DNN', '15', 'GT', '11', '', '', '', ' 2.Số thuế GTGT được khấu trừ phát sinh', ' 2.Số thuế GTGT được khấu trừ phát sinh', 'NO-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6917, 'DNN', '15', 'GT', '12', '', '', '', ' 3.Số thuế GTGT đã được khấu trừ ,đã hoàn lại ,thuế GTGT', ' 3.Số thuế GTGT đã được khấu trừ ,đã hoàn lại ,thuế GTGT', 'CO-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6918, 'DNN', '15', 'GT', '', '', '', '', '    hàng mua trả lại và không được khấu trừ  ( 12 = 13 + 14 +15 )', '    hàng mua trả lại và không được khấu trừ  ( 12 = 13 + 14 +15 )', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6919, 'DNN', '15', 'GT', '', '', '', '', '    Trong đó :', '    Trong đó :', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6920, 'DNN', '15', 'GT', '13', '', '', '', ' a.Số thuế giá trị gia tăng đã khấu trừ', ' a.Số thuế giá trị gia tăng đã khấu trừ', '3331/133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6921, 'DNN', '15', 'GT', '14', '', '', '', ' b.Số thuế giá trị gia tăng đã hoàn lại', ' b.Số thuế giá trị gia tăng đã hoàn lại', '133/133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6922, 'DNN', '15', 'GT', '15', '', '', '', ' c.Số thuế giá trị gia tăng hàng mua trả lại ,giãm giá hàng mua', ' c.Số thuế giá trị gia tăng hàng mua trả lại ,giãm giá hàng mua', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6923, 'DNN', '15', 'GT', '16', '', '', '', ' d.Số thuế giá trị gia tăng không được khấu trừ', ' c.Số thuế giá trị gia tăng không được khấu trừ', '142/133,632/133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6924, 'DNN', '15', 'GT/', '17', '', '', '', ' 4.Số thuế GTGT còn được khấu trừ ,hoàn lại', ' 4.Số thuế GTGT còn được khấu trừ ,hoàn lại', 'CK-133', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6925, 'DNN', '15', 'GT', '', '', '', '', '    cuối kỳ  ( 16 = 10+11-12)', '    cuối kỳ  ( 16 = 10+11-12)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6926, 'DNN', '15', 'GT*', '', '', '', '', 'II - Thuế giá trị gia tăng được hoàn lại', 'II - Thuế giá trị gia tăng được hoàn lại', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6927, 'DNN', '15', 'GT/', '20', '', '', '', ' 1. Thuế giá trị gia tăng còn được hoàn lại đầu kỳ', ' 1. Thuế giá trị gia tăng còn được hoàn lại đầu kỳ', 'DK-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6928, 'DNN', '15', 'GT', '21', '', '', '', ' 2. Thuế giá trị gia tăng được hoàn lại phát sinh', ' 2. Thuế giá trị gia tăng được hoàn lại', 'NO-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6929, 'DNN', '15', 'GT', '22', '', '', '', ' 3. Thuế giá trị gia tăng đã hoàn lại', ' 3. Thuế giá trị gia tăng đã hoàn lại', 'CO-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6930, 'DNN', '15', 'GT/', '23', '', '', '', ' 4. Thuế GTGT còn được hoàn lại cuối kỳ cuối kỳ  ( 23 = 20 + 21 - 22)', ' 4. Thuế GTGT còn được hoàn lại cuối kỳ cuối kỳ  ( 23 = 20 + 21 - 22)', 'CK-13310', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6931, 'DNN', '15', 'GT*', '', '', '', '', 'III - Thuế giá trị gia tăng được giảm', 'III - Thuế giá trị gia tăng được miển giãm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6932, 'DNN', '15', 'GT/', '30', '', '', '', ' 1. Thuế giá trị gia tăng còn được giãm đầu kỳ', ' 1. Thuế giá trị gia tăng còn được miển giãm đầu kỳ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6933, 'DNN', '15', 'GT', '31', '', '', '', ' 2. Thuế giá trị gia tăng được giảm phát sinh', ' 2. Thuế giá trị gia tăng được miển giãm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6934, 'DNN', '15', 'GT', '32', '', '', '', ' 3. Thuế giá trị gia tăng đã được giảm', ' 3. Thuế giá trị gia tăng đã được miển giãm', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6935, 'DNN', '15', 'GT/', '33', '', '', '', ' 4. Thuế GTGTcòn được giãm cuối kỳ  ( 33 = 30 + 31 - 32)', ' 4. Thuế GTGTcòn được giãm cuối kỳ  ( 33 = 30 + 31 - 32)', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6936, 'DNN', '15', 'GT*', '', '', '', '', 'IV - Thuế giá trị gia tăng hàng bán nội địa', 'IV - Thuế giá trị gia tăng hàng bán nội địa', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6937, 'DNN', '15', 'GT/', '40', '', '', '', ' 1.Thuế giá trị gia tăng đầu ra còn phải nộp đầu kỳ', ' 1.Thuế giá trị gia tăng đầu ra còn phải nộp đầu kỳ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6938, 'DNN', '15', 'GT', '41', '', '', '', ' 2.Thuế giá trị gia tăng đầu ra phát sinh', ' 2.Thuế giá trị gia tăng đầu ra phát sinh', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6939, 'DNN', '15', 'GT', '42', '', '', '', ' 3.Thuế giá trị gia tăng đầu vào đã khấu trừ', ' 3.Thuế giá trị gia tăng đầu vào đã khấu trừ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6940, 'DNN', '15', 'GT', '43', '', '', '', ' 4.Thuế giá trị gia tăng hàng bán bị trả lại ,bị giảm giá', ' 4.Thuế giá trị gia tăng hàng bán bị trả lại ,bị giảm giá', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6941, 'DNN', '15', 'GT', '44', '', '', '', ' 5.Thuế giá trị gia tăng được giảm trừ vào số thuế phải nộp', ' 5.Thuế giá trị gia tăng được giảm trừ vào số thuế phải nộp', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6942, 'DNN', '15', 'GT', '45', '', '', '', ' 6.Thuế giá trị gia tăng hàng bán nội địa đã nộp vào NSNN', ' 6.Thuế giá trị gia tăng hàng bán nội địa đã nộp vào NSNN', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6943, 'DNN', '15', 'GT/', '46', '', '', '', ' 7.Thuế giá trị gia tăng hàng bán nội địa còn phải nộp cuối kỳ', ' 7.Thuế giá trị gia tăng hàng bán nội địa còn phải nộp cuối kỳ', '', '0.00', '0.00', '0.00', '0.00', '0.00'),
(6944, 'DNN', '15', 'GT', '', '', '', '', '     ( 46 = 40+41-42-43-44-45 )', '     ( 46 = 40+41-42-43-44-45 )', '', '0.00', '0.00', '0.00', '0.00', '0.00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `lctiente`
--

DROP TABLE IF EXISTS `lctiente`;
CREATE TABLE `lctiente` (
  `id` int(10) NOT NULL,
  `chedokt` char(10) NOT NULL,
  `kyhieu` char(2) NOT NULL,
  `swt` char(3) NOT NULL,
  `maso` char(2) NOT NULL,
  `tminh` char(6) NOT NULL,
  `chitieu` char(100) NOT NULL,
  `chitieuu` char(100) NOT NULL,
  `dau` smallint(6) NOT NULL,
  `tkmoi` char(8) NOT NULL,
  `cachtinh` char(35) NOT NULL,
  `kytruoc` decimal(15,2) NOT NULL,
  `kynay` decimal(15,2) NOT NULL,
  `kytruoclk` decimal(15,2) NOT NULL,
  `kynaylk` decimal(15,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `lctiente`
--

INSERT INTO `lctiente` (`id`, `chedokt`, `kyhieu`, `swt`, `maso`, `tminh`, `chitieu`, `chitieuu`, `dau`, `tkmoi`, `cachtinh`, `kytruoc`, `kynay`, `kytruoclk`, `kynaylk`) VALUES
(2551, 'DNL', '04', 'GT*', '', '', 'I - LƯU CHUYÊN TIÊN TƯ HOAT ĐÔNG SXKD', 'I - CASH FLOW FROM PRODUCTION AND BUSINESS', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2552, 'DNL', '04', 'GT/', '01', '', '  Lợi nhuận trước thuế :', '  Profit before tax :', 1, '', '911/421', '0.00', '215951656.00', '0.00', '0.00'),
(2553, 'DNL', '04', 'GT/', '', '', '  Điều chỉnh cho các khoản :', '', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2554, 'DNL', '04', 'GT', '02', '', '    - Khấu hao tài sản cố định', '    - Fixed assets depreciation', -1, '', '6/214', '0.00', '-114301836.00', '0.00', '0.00'),
(2555, 'DNL', '04', 'GT', '03', '', '    - Các khoản dự phòng', '    - Reserves', -1, '', 'C-D 129,139,159,129,229', '0.00', '0.00', '0.00', '0.00'),
(2556, 'DNL', '04', 'GT', '04', '', '    - Lãi ,lổ do bán TSCĐ', '    - Surplus or loss from fixed assets sale', -1, '42121', '911/42121', '0.00', '0.00', '0.00', '0.00'),
(2557, 'DNL', '04', 'GT', '05', '', '    - Lãi ,lổ do đánh giá lại TS ,đổi tiền tệ', '    - Surplus or loss from fixed assets revalua', -1, '42123', '911/42123', '0.00', '0.00', '0.00', '0.00'),
(2558, 'DNL', '04', 'GT', '06', '', '    - Lãi do đầu tư vào các đơn vị khác', '    - Benifit from financial investment', -1, '42122', '911/42122', '0.00', '0.00', '0.00', '0.00'),
(2559, 'DNL', '04', 'GT', '07', '', '    - Thu lãi tiền gửi', '    - Interest earnings', -1, '7112', '11/7112', '0.00', '0.00', '0.00', '0.00'),
(2560, 'DNL', '04', 'GT/', '10', '', ' 3. Lợi nhuận k/doanh trước thay đổi vốn lưu độ', ' 3. Business profit by working capital changes', 1, '', 'Z(01+02+03+04+05+06+07)', '0.00', '101649820.00', '0.00', '0.00'),
(2561, 'DNL', '04', 'GT', '11', '', '    - Tăng giảm các khoản phải thu', '    - Increase or decrease of receivables', -1, '', 'C-D 131,136,138,141,142,144', '0.00', '-2150648847.00', '0.00', '0.00'),
(2562, 'DNL', '04', 'GT', '12', '', '    - Tăng giảm hàng tồn kho', '    - Increase or decrease of inventories', -1, '', 'C-D 151,152,153,154,155,156,157', '0.00', '1371560405.00', '0.00', '0.00'),
(2563, 'DNL', '04', 'GT', '13', '', '    - Tăng giảm các khoản phải trả', '    - Increase or decrease of payables', -1, '', 'C-D 315,331,333,334,335,336,338', '0.00', '11454924479.00', '0.00', '0.00'),
(2564, 'DNL', '04', 'GT', '14', '', '    - Tiền thu từ các khoản khác', '    - Other receipts', 1, '', '', '0.00', '2117165141.00', '0.00', '0.00'),
(2565, 'DNL', '04', 'GT', '15', '', '    - Tiền chi cho các khoản khác', '    - Other payments', -1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2566, 'DNL', '04', 'GT/', '20', '', '  Lưu chuyển tiền tệ thuần từ hoạt động SXKD', '  Net cash flow from production and business', 1, '', 'Z(10+11+12+13+14+15)', '0.00', '12894650998.00', '0.00', '0.00'),
(2567, 'DNL', '04', 'GT*', '', '', 'II - LƯU CHUYÊN TIÊN TƯ HOAT ĐÔNG ĐÂU TƯ', 'II - CASH FLOW FROM FINANCIAL INVESTMENT', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2568, 'DNL', '04', 'GT', '21', '', '    - Tiền thu hồi các khoản đ.tư vào đ.vị khác', '    - Returns from other invested units', 1, '', '11/121,128,221,222,228', '0.00', '10000000.00', '0.00', '0.00'),
(2569, 'DNL', '04', 'GT', '22', '', '    - Tiền thu từ lãi khoản đ.tư vào đ.vị khác', '    - Investment benifits from invested units', 1, '7111', '11/7111', '0.00', '0.00', '0.00', '0.00'),
(2570, 'DNL', '04', 'GT', '23', '', '    - Tiền thu do bán tài sản cố định', '    - Receipts from fixed assets sale', 1, '7211', '11/7211', '0.00', '0.00', '0.00', '0.00'),
(2571, 'DNL', '04', 'GT', '24', '', '    - Tiền đầu tư vào các đơn vị khác', '    - Financial investment on other units', -1, '', '121,128,221,222,228/11', '0.00', '0.00', '0.00', '0.00'),
(2572, 'DNL', '04', 'GT', '25', '', '    - Tiền mua tài sản cố định', '    - Fixed assets purchases', -1, '', '211,212,213/11', '0.00', '-7595800.00', '0.00', '0.00'),
(2573, 'DNL', '04', 'GT/', '30', '', '  Lưu chuyển tiền tệ thuần từ hoạt động đầu tư', '  Net cash flow from financial investment', 1, '', 'Z(21+22+23+24+25)', '0.00', '2404200.00', '0.00', '0.00'),
(2574, 'DNL', '04', 'GT*', '', '', 'III - LƯU CHUYÊN TIÊN TƯ HOAT ĐÔNG TAI CHINH', 'III - CASH FLOW FROM FINANCIAL ACTIVITIES', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2575, 'DNL', '04', 'GT', '31', '', '    - Tiền thu do đi vay', '    - Receipts from borrowings', 1, '', '11/311,341,342', '0.00', '3068061223.00', '0.00', '0.00'),
(2576, 'DNL', '04', 'GT', '32', '', '    - Tiền thu do các chủ sở hữu góp vốn', '    - Receipts from owner`s equity', 1, '', '11/411', '0.00', '0.00', '0.00', '0.00'),
(2577, 'DNL', '04', 'GT', '33', '', '    - Tiền thu từ lãi tiền gửi', '    - Interest earnings', 1, '7112', '11/7112', '0.00', '0.00', '0.00', '0.00'),
(2578, 'DNL', '04', 'GT', '34', '', '    - Tiền đã trả nợ vay', '    - Paid debt services', -1, '', '311,341,342/11', '0.00', '-15713797000.00', '0.00', '0.00'),
(2579, 'DNL', '04', 'GT', '35', '', '    - Tiền đã hoàn vốn cho các chủ sở hữu', '    - Return to owners', -1, '33381', '411,33381/11', '0.00', '0.00', '0.00', '0.00'),
(2580, 'DNL', '04', 'GT', '36', '', '    - Tiền lãi đã trả cho các nhà đ.tư vào DN', '    - Interest paid to investors', -1, '7111', '7111,431/11', '0.00', '-8919000.00', '0.00', '0.00'),
(2581, 'DNL', '04', 'GT/', '40', '', '  Lưu chuyển tiền tệ thuần từ h/động tài chính', '  Net cash flow from financial activities', 1, '', 'Z(31+32+33+34+35+36)', '0.00', '-12654654777.00', '0.00', '0.00'),
(2582, 'DNL', '04', 'GT*', '50', '', '  Lưu chuyển tiền tệ thuần trong kỳ', '  Net cash flow in current period', 1, '', 'Z(20+30+40)', '0.00', '242400421.00', '0.00', '0.00'),
(2583, 'DNL', '04', 'GT*', '60', '', '  Tiền tồn đầu kỳ', '  Opening period balance', 1, '', 'C-D 11', '322448721.00', '322448721.00', '0.00', '0.00'),
(2584, 'DNL', '04', 'GT*', '70', '', '  Tiền tồn cuối kỳ', '  Closing period balance', 1, '', 'Z(50+60)', '322448721.00', '564849142.00', '0.00', '0.00'),
(2585, 'DNL', '04', '---', '--', '', '-----------------------------------------------', '-----------------------------------------------', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2586, 'DNL', '04', 'TT*', '', '', 'I - LƯU CHUYÊN TIÊN TƯ HOAT ĐÔNG SXKD', 'I - CASH FLOW FROM PRODUCTION AND BUSINESS', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2587, 'DNL', '04', 'TT', '01', '', '  1. Tiền thu bán hàng', '  1. Sale turnover', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2588, 'DNL', '04', 'TT', '02', '', '  2. Tiền thu từ các khoản nợ phải thu', '  2. Receipts from receivable loans', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2589, 'DNL', '04', 'TT', '03', '', '  3. Tiền thu từ các khoản khác', '  3. Other receipts', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2590, 'DNL', '04', 'TT', '04', '', '  4. Tiền đã trả cho người bán', '  4. Paid payment to sellers', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2591, 'DNL', '04', 'TT/', '05', '', '  5. Tiền đã trả cho công nhân viên', '  5. Paid payment to employees', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2592, 'DNL', '04', 'TT', '06', '', '  6. Tiền đã nộp thuế và các khoản khác cho NN', '  6. Tax and other contributions to goverment', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2593, 'DNL', '04', 'TT', '07', '', '  7. Tiền đã trả cho các khoản nợ phải trả khác', '  7. Payment paid to payable debts', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2594, 'DNL', '04', 'TT', '08', '', '  8. Tiền đã trả cho các khoản khác', '  8. Other paid payments', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2595, 'DNL', '04', 'TT/', '20', '', '  Lưu chuyển tiền tệ thuần từ hoạt động SXKD', '  Net cash flow from production and business', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2596, 'DNL', '04', 'TT*', '', '', 'II - LƯU CHUYÊN TIÊN TƯ HOAT ĐÔNG ĐÂU TƯ', 'II - CASH FLOW FROM FINANCIAL INVESTMENT', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2597, 'DNL', '04', 'TT', '21', '', '  1. Tiền thu hồi các khoản đầu tư vào đv khác', '  1. Return from other invested units', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2598, 'DNL', '04', 'TT', '22', '', '  2. Tiền thu từ lãi các khoản đ.tư vào đv khác', '  2. interest from invested units', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2599, 'DNL', '04', 'TT', '23', '', '  3. Tiền thu do bán tài sản cố định', '  3. Receipts from fixed assets sale', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2600, 'DNL', '04', 'TT', '24', '', '  4. Tiền đầu tư vào đơn vị khác', '  4. Financial investment on others', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2601, 'DNL', '04', 'TT', '25', '', '  5. Tiền mua tài sản cố định', '  5. Fixed assets purchases', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2602, 'DNL', '04', 'TT/', '30', '', '  Lưu chuyển tiền tệ thuần từ hoạt động đầu tư', '  Net cash flow from financial investment', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2603, 'DNL', '04', 'TT*', '', '', 'III - LƯU CHUYÊN TIÊN TƯ HOAT ĐÔNG TAI CHINH', 'III - CASH FLOW FROM FINANCIAL ACTIVITIES', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2604, 'DNL', '04', 'TT', '31', '', '  1. Tiền thu do đi vay', '  1. Receipts from borrowings', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2605, 'DNL', '04', 'TT', '32', '', '  2. Tiền thu do các chủ sở hữu góp vốn', '  2. Receipts from owner`s equity', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2606, 'DNL', '04', 'TT', '33', '', '  3. Tiền thu từ lãi tiền gửi', '  3. Interest earnings', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2607, 'DNL', '04', 'TT', '34', '', '  4. Tiền đã trả nợ vay', '  4. Paid payment of debt', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2608, 'DNL', '04', 'TT', '35', '', '  5. Tiền đã hoàn vốn cho các chủ sở hữu', '  5. Returns to owners', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2609, 'DNL', '04', 'TT', '36', '', '  6. Tiền lãi đã trả cho các nhà đầu tư vào DN', '  6. Interest paid to investors', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2610, 'DNL', '04', 'TT/', '40', '', '  Lưu chuyển tiền tệ thuần từ h/động tài chính', '  Net cash flow from financial activity', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2611, 'DNL', '04', 'TT*', '50', '', '  Lưu chuyển tiền thuần trong kỳ', '  Net cash flow in current period', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2612, 'DNL', '04', 'TT*', '60', '', '  Tiền tồn đầu kỳ', '  Opening period balance', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2613, 'DNL', '04', 'TT*', '70', '', '  Tiền tồn cuối kỳ', '  Closing period balance', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2614, 'DNL', '05', 'GT*', '', '', 'I. Lưu chuyển tiền từ hoạt động kinh doanh', '', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2615, 'DNL', '05', 'GT*', '01', '', '1. Lợi nhuận trước thuế', '  Profit before tax :', 1, '', '911/421,821', '231317951018.00', '231317951018.00', '231317951018.00', '231317951018.00'),
(2616, 'DNL', '05', 'GT*', '', '', '2. Điều chỉnh cho các khoản', '', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2617, 'DNL', '05', 'GT', '02', '', '    - Khấu hao TSCĐ', '    - Fixed assets depreciation', -1, '', '6/214', '-1221709007.00', '-1221709007.00', '-1221709007.00', '-1221709007.00'),
(2618, 'DNL', '05', 'GT', '03', '', '    - Các khoản dự phòng', '    - Reserves', -1, '', 'C-D 129,139,159,229', '0.00', '0.00', '0.00', '0.00'),
(2619, 'DNL', '05', 'GT', '04', '', '    - Lãi, lổ chênh lệch tỷ giá hối đoái chưa thực hiện', '', -1, '42121', '911/42121', '0.00', '0.00', '0.00', '0.00'),
(2620, 'DNL', '05', 'GT', '05', '', '    - Lãi, lổ từ hoạt động đầu tư', '', -1, '42122', '911/42122', '0.00', '0.00', '0.00', '0.00'),
(2621, 'DNL', '05', 'GT', '06', '', '    - Chi phí lãi vay', '', -1, '635v', '635v/311,11', '0.00', '0.00', '0.00', '0.00'),
(2622, 'DNL', '05', 'GT*', '08', '', '3. Lợi nhuận từ hoạt động kinh doanh trước thay đổi vốn  lưu động', ' 3. Business profit by working capital changes', 1, '', 'Z(01+02+03+04+05+06)', '230096242011.00', '230096242011.00', '230096242011.00', '230096242011.00'),
(2623, 'DNL', '05', 'GT', '09', '', '    - Tăng giảm các khoản phải thu', '    - Increase or decrease of receivables', -1, '', 'C-D 131,136,138,141,144', '-261902799899.00', '-261902799899.00', '-261902799899.00', '-261902799899.00'),
(2624, 'DNL', '05', 'GT', '10', '', '    - Tăng giảm hàng tồn kho', '    - Increase or decrease of inventories', -1, '', 'C-D 151,152,153,154,155,156,157', '8863828900.00', '8863828900.00', '8863828900.00', '8863828900.00'),
(2625, 'DNL', '05', 'GT', '11', '', '    - Tăng giảm các khoản phải trả (không kể lãi vay phải trả, thuế TN phải nộp)', '    - Increase or decrease of payables', -1, '', 'C-D 315,331,333,334,335,336,337,338', '14653486059.00', '14653486059.00', '14653486059.00', '14653486059.00'),
(2626, 'DNL', '05', 'GT', '12', '', '    - Tăng giảm chi phí trả trước', '', -1, '', 'C-D 142,242', '153967206.00', '153967206.00', '153967206.00', '153967206.00'),
(2627, 'DNL', '05', 'GT', '13', '', '    - Tiền lãi vay đã trả', '', -1, '335v', '335v/11,311', '0.00', '0.00', '0.00', '0.00'),
(2628, 'DNL', '05', 'GT', '14', '', '    - Thuế thu nhập doanh nghiệp đã nộp', '', -1, '', '3334/11,311', '-181731195.00', '-181731195.00', '-181731195.00', '-181731195.00'),
(2629, 'DNL', '05', 'GT', '15', '', '    - Tiền thu khác từ hoạt động kinh doanh', '', 1, '', '', '-2206375357.00', '-2206375357.00', '-2206375357.00', '-2206375357.00'),
(2630, 'DNL', '05', 'GT', '16', '', '    - Tiền chi khác từ hoạt động kinh doanh', '', -1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2631, 'DNL', '05', 'GT/', '20', '', 'Lưu chuyển tiền thuần từ hoạt động kinh doanh', '  Net cash flow from production and business', 1, '', 'Z(08+09+10+11+12+13+14+15+16)', '-10523382275.00', '-10523382275.00', '-10523382275.00', '-10523382275.00'),
(2632, 'DNL', '05', 'GT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2633, 'DNL', '05', 'GT*', '', '', 'II. Lưu chuyển tiền từ hoạt động đầu tư', 'II - CASH FLOW FROM FINANCIAL INVESTMENT', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2634, 'DNL', '05', 'GT', '21', '', '1.Tiền chi để mua sắm, xây dựng TSCĐ và các tài sản dài hạn khác', '    - Fixed assets purchases', -1, '', '211,212,213,217/11,311', '-403123637.00', '-403123637.00', '-403123637.00', '-403123637.00'),
(2635, 'DNL', '05', 'GT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2636, 'DNL', '05', 'GT', '22', '', '2.Tiền thu từ thanh lý, nhượng bán TSCĐ và các tài sản dài hạn khác', '    - Receipts from fixed assets sale', 1, '7112', '11/7112', '0.00', '0.00', '0.00', '0.00'),
(2637, 'DNL', '05', 'GT', '23', '', '3.Tiền chi cho vay, mua các công cụ nợ của đơn vị khác', '', -1, '1388v', '1388v/11', '0.00', '0.00', '0.00', '0.00'),
(2638, 'DNL', '05', 'GT', '24', '', '4.Tiền thu hồi cho vay, bán lại các công cụ nợ của đơn vị khác', '', 1, '1388v', '11/1388v', '0.00', '0.00', '0.00', '0.00'),
(2639, 'DNL', '05', 'GT', '25', '', '5. Tiền chi đầu tư góp vốn vào đơn vị khác', '', -1, '', '121,128,221,222,228/11,311', '0.00', '0.00', '0.00', '0.00'),
(2640, 'DNL', '05', 'GT', '26', '', '6. Tiền thu hồi đầu tư góp vốn vào đơn vị khác', '    - Returns from other invested units', 1, '', '11/121,128,221,222,228', '0.00', '0.00', '0.00', '0.00'),
(2641, 'DNL', '05', 'GT', '27', '', '7. Tiền thu lãi cho vay, cổ tức và lợi nhuận được chia', '', 1, '7113', '11/7113', '0.00', '0.00', '0.00', '0.00'),
(2642, 'DNL', '05', 'GT/', '30', '', 'Lưu chuyển tiền thuần từ hoạt động đầu tư', '  Net cash flow from financial investment', 1, '', 'Z(21+22+23+24+25+26+27)', '-403123637.00', '-403123637.00', '-403123637.00', '-403123637.00'),
(2643, 'DNL', '05', 'GT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2644, 'DNL', '05', 'GT*', '', '', 'III. Lưu chuyển tiền từ hoạt động tài chính', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2645, 'DNL', '05', 'GT', '31', '', '1.Tiền thu từ phát hành cổ phiếu, nhận vốn góp của chủ sở hữu', '', 1, '', '11/411', '10000000000.00', '10000000000.00', '10000000000.00', '10000000000.00'),
(2646, 'DNL', '05', 'GT', '32', '', '2.Tiền chi trả vốn góp cho các chủ sở hữu, mua lại cổ phiếu của DN đã phát hành', '', -1, '', '411/11', '0.00', '0.00', '0.00', '0.00'),
(2647, 'DNL', '05', 'GT', '33', '', '3. Tiền vay ngắn hạn, dài hạn nhận được', '', 1, '', '11/311,341', '27036000000.00', '27036000000.00', '27036000000.00', '27036000000.00'),
(2648, 'DNL', '05', 'GT', '34', '', '4. Tiền chi trả nợ gốc vay', '', -1, '', '311,341/11', '-24193047000.00', '-24193047000.00', '-24193047000.00', '-24193047000.00'),
(2649, 'DNL', '05', 'GT', '35', '', '5. Tiền chi trả nợ thuê tài chính', '', -1, '', '342/11,311', '0.00', '0.00', '0.00', '0.00'),
(2650, 'DNL', '05', 'GT', '36', '', '6. Cổ tức, lợi nhuận đã trả cho chủ sở hữu', '', -1, '3388c', '3388c/11,311', '0.00', '0.00', '0.00', '0.00'),
(2651, 'DNL', '05', 'GT/', '40', '', 'Lưu chuyển tiền thuần từ hoạt động tài chính', '', 1, '', 'Z(31+32+33+34+35+36)', '12842953000.00', '12842953000.00', '12842953000.00', '12842953000.00'),
(2652, 'DNL', '05', 'GT*', '50', '', 'Lưu chuyển tiền thuần trong kỳ (50=20+30+40)', '', 1, '', 'Z(20+30+40)', '1916447088.00', '1916447088.00', '1916447088.00', '1916447088.00'),
(2653, 'DNL', '05', 'GT*', '60', '', 'Tiền và tương đương tiền đầu kỳ', '', 1, '', 'C-D 11', '4858679128.00', '4858679128.00', '4858679128.00', '4858679128.00'),
(2654, 'DNL', '05', 'GT', '61', '', 'Ảnh hưởng của thay đổi tỷ giá hối đoái quy đổi ngoại tệ', '', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2655, 'DNL', '05', 'GT*', '70', 'VI.31', 'Tiền và tương đương tiền cuối kỳ (50+60+61)', '', 1, '', 'Z(50+60)', '6775126216.00', '6775126216.00', '6775126216.00', '6775126216.00'),
(2656, 'DNL', '05', 'TT*', '', '', 'I.Lưu chuyển tiền thuần từ hoạt động kinh doanh', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2657, 'DNL', '05', 'TT', '01', '', '1. Tiền thu từ bán hàng, cung cấp dịch vụ và doanh thu khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2658, 'DNL', '05', 'TT', '02', '', '2. Tiền chi trả cho người cung cấp hàng hóa và dịch vụ', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2659, 'DNL', '05', 'TT', '03', '', '3. Tiền chi trả cho người lao động', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2660, 'DNL', '05', 'TT', '04', '', '4. Tiền chi trả lãi vay', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2661, 'DNL', '05', 'TT', '05', '', '5. Tiền chi nộp thuế Thu nhập doanh nghiệp', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2662, 'DNL', '05', 'TT', '06', '', '6. Tiền thu khác từ hoạt động kinh doanh', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2663, 'DNL', '05', 'TT', '07', '', '7. Tiền chi khác cho hoạt động kinh doanh', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2664, 'DNL', '05', 'TT/', '20', '', 'Lưu chuyển tiền thuần từ hoạt động kinh doanh', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2665, 'DNL', '05', 'TT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2666, 'DNL', '05', 'TT*', '', '', 'II. Lưu chuyển tiền từ hoạt động đầu tư', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2667, 'DNL', '05', 'TT', '21', '', '1.Tiền chi để mua sắm, xây dựng TSCĐ và các tài sản dài hạn khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2668, 'DNL', '05', 'TT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2669, 'DNL', '05', 'TT', '22', '', '2.Tiền thu từ thanh lý, nhượng bán TSCĐ và các tài sản dài hạn khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2670, 'DNL', '05', 'TT', '23', '', '3. Tiền chi cho vay, mua các công cụ nợ của đơn vị khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2671, 'DNL', '05', 'TT', '24', '', '4.Tiền thu hồi cho vay, bán lại các công cụ nợ của đơn vị khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2672, 'DNL', '05', 'TT', '25', '', '5. Tiền chi đầu tư góp vốn vào đơn vị khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2673, 'DNL', '05', 'TT', '26', '', '6. Tiền thu hồi đầu tư góp vốn vào đơn vị khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2674, 'DNL', '05', 'TT', '27', '', '7. Tiền thu lãi cho vay, cổ tức và lợi nhuận được chia', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2675, 'DNL', '05', 'TT/', '30', '', 'Lưu chuyển tiền thuần từ hoạt động đầu tư', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2676, 'DNL', '05', 'TT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2677, 'DNL', '05', 'TT*', '', '', 'III. Lưu chuyển tiền từ hoạt động tài chính', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2678, 'DNL', '05', 'TT', '31', '', '1.Tiền thu từ phát hành cổ phiếu, nhận vốn góp của chủ sở hữu', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2679, 'DNL', '05', 'TT', '32', '', '2.Tiền chi trả vốn góp cho các chủ sở hữu, mua lại cổ phiếu của DN đã phát hành', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2680, 'DNL', '05', 'TT', '33', '', '3. Tiền vay ngắn hạn, dài hạn nhận được', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2681, 'DNL', '05', 'TT', '34', '', '4. Tiền chi trả nợ gốc vay', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2682, 'DNL', '05', 'TT', '35', '', '5. Tiền chi trả nợ thuê tài chính', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2683, 'DNL', '05', 'TT', '36', '', '6. Cổ tức, lợi nhuận đã trả cho chủ sở hữu', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2684, 'DNL', '05', 'TT/', '40', '', 'Lưu chuyển tiền thuần từ hoạt động tài chính', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2685, 'DNL', '05', 'TT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2686, 'DNL', '05', 'TT*', '50', '', 'Lưu chuyển tiền thuần trong kỳ (50=20+30+40)', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2687, 'DNL', '05', 'TT*', '60', '', 'Tiền và tương đương tiền đầu kỳ', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2688, 'DNL', '05', 'TT', '61', '', 'Ảnh hưởng của thay đổi tỷ giá hối đoái quy đổi ngoại tệ', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2689, 'DNL', '05', 'TT*', '70', 'VII34', 'Tiền và tương đương tiền cuối kỳ (50+60+61)', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2690, 'DNL', '15', 'GT*', '', '', 'I. Lưu chuyển tiền từ hoạt động kinh doanh', '', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2691, 'DNL', '15', 'GT*', '01', '', '1. Lợi nhuận trước thuế', '  Profit before tax :', 1, '', '911/421,821', '273231268.00', '1292809425.00', '864585101.00', '1292809425.00'),
(2692, 'DNL', '15', 'GT*', '', '', '2. Điều chỉnh cho các khoản', '', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2693, 'DNL', '15', 'GT', '02', '', '    - Khấu hao TSCĐ và BĐSĐT', '    - Fixed assets depreciation', -1, '', '6/214', '-487315262.00', '-1977584621.00', '-1429215868.00', '-1977584621.00'),
(2694, 'DNL', '15', 'GT', '03', '', '    - Các khoản dự phòng', '    - Reserves', -1, '', 'C-D 129,139,159,229', '0.00', '111226000.00', '0.00', '111226000.00'),
(2695, 'DNL', '15', 'GT', '04', '', '    - Lãi, lổ chênh lệch tỷ giá hối đoái  do đánh giá lại các khoản mục  ngoại tệ', '', -1, '42121', '911/42121', '0.00', '0.00', '0.00', '0.00'),
(2696, 'DNL', '15', 'GT', '05', '', '    - Lãi, lổ từ hoạt động đầu tư', '', -1, '42122', '911/42122', '0.00', '0.00', '0.00', '0.00'),
(2697, 'DNL', '15', 'GT', '06', '', '    - Chi phí lãi vay', '', -1, '635v', '635v/311,11', '0.00', '0.00', '0.00', '0.00'),
(2698, 'DNL', '15', 'GT', '07', '', '    - Các khoản điều chỉnh khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2699, 'DNL', '15', 'GT*', '08', '', '3. Lợi nhuận từ hoạt động kinh doanh trước thay đổi vốn  lưu động', ' 3. Business profit by working capital changes', 1, '', 'Z(01+02+03+04+05+06)', '-214083994.00', '-573549196.00', '-564630767.00', '-573549196.00'),
(2700, 'DNL', '15', 'GT', '09', '', '    - Tăng giảm các khoản phải thu', '    - Increase or decrease of receivables', -1, '', 'C-D 131,136,138,141,144', '-76960754.00', '8679720.00', '-2037250186.00', '8679720.00'),
(2701, 'DNL', '15', 'GT', '10', '', '    - Tăng giảm hàng tồn kho', '    - Increase or decrease of inventories', -1, '', 'C-D 151,152,153,154,155,156,157', '491685864.00', '-646793757.00', '1491318047.00', '-646793757.00'),
(2702, 'DNL', '15', 'GT', '11', '', '    - Tăng giảm các khoản phải trả (không kể lãi vay phải trả, thuế TN phải nộp)', '    - Increase or decrease of payables', -1, '', 'C-D 315,331,333,334,335,336,337,338', '1103689522.00', '-330664175.00', '-84596969.00', '-330664175.00'),
(2703, 'DNL', '15', 'GT', '12', '', '    - Tăng giảm chi phí trả trước', '', -1, '', 'C-D 142,242', '98247506.00', '134247506.00', '134247506.00', '134247506.00'),
(2704, 'DNL', '15', 'GT', '13', '', '    - Tăng giảm chứng khoán kinh doanh', '', -1, '', 'C-D 121', '0.00', '0.00', '0.00', '0.00'),
(2705, 'DNL', '15', 'GT', '14', '', '    - Tiền lãi vay đã trả', '', -1, '335v', '335v/11,311', '0.00', '0.00', '0.00', '0.00'),
(2706, 'DNL', '15', 'GT', '15', '', '    - Thuế thu nhập doanh nghiệp đã nộp', '', -1, '', '3334/11,311', '0.00', '-12264061.00', '-12264061.00', '-12264061.00'),
(2707, 'DNL', '15', 'GT', '16', '', '    - Tiền thu khác từ hoạt động kinh doanh', '', 1, '', '', '2096155812.00', '19619012203.00', '12875690366.00', '19619012203.00'),
(2708, 'DNL', '15', 'GT', '17', '', '    - Tiền chi khác từ hoạt động kinh doanh', '', -1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2709, 'DNL', '15', 'GT/', '20', '', 'Lưu chuyển tiền thuần từ hoạt động kinh doanh', '  Net cash flow from production and business', 1, '', 'Z(08+09+10+11+12+13+14+15+16+17)', '3712817950.00', '18772217436.00', '12367144703.00', '18772217436.00'),
(2710, 'DNL', '15', 'GT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2711, 'DNL', '15', 'GT*', '', '', 'II. Lưu chuyển tiền từ hoạt động đầu tư', 'II - CASH FLOW FROM FINANCIAL INVESTMENT', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2712, 'DNL', '15', 'GT', '21', '', '1.Tiền chi để mua sắm, xây dựng TSCĐ và các tài sản dài hạn khác', '    - Fixed assets purchases', -1, '', '211,212,213,217/11,311', '0.00', '0.00', '0.00', '0.00'),
(2713, 'DNL', '15', 'GT', '22', '', '2.Tiền thu từ thanh lý, nhượng bán TSCĐ và các tài sản dài hạn khác', '    - Receipts from fixed assets sale', 1, '7112', '11/7112', '0.00', '0.00', '0.00', '0.00'),
(2714, 'DNL', '15', 'GT', '23', '', '3.Tiền chi cho vay, mua các công cụ nợ của đơn vị khác', '', -1, '1388v', '1388v/11', '0.00', '0.00', '0.00', '0.00'),
(2715, 'DNL', '15', 'GT', '24', '', '4.Tiền thu hồi cho vay, bán lại các công cụ nợ của đơn vị khác', '', 1, '1388v', '11/1388v', '0.00', '0.00', '0.00', '0.00'),
(2716, 'DNL', '15', 'GT', '25', '', '5. Tiền chi đầu tư góp vốn vào đơn vị khác', '', -1, '', '121,128,221,222,228/11,311', '0.00', '0.00', '0.00', '0.00'),
(2717, 'DNL', '15', 'GT', '26', '', '6. Tiền thu hồi đầu tư góp vốn vào đơn vị khác', '    - Returns from other invested units', 1, '', '11/121,128,221,222,228', '0.00', '0.00', '0.00', '0.00'),
(2718, 'DNL', '15', 'GT', '27', '', '7. Tiền thu lãi cho vay, cổ tức và lợi nhuận được chia', '', 1, '7113', '11/7113', '0.00', '0.00', '0.00', '0.00'),
(2719, 'DNL', '15', 'GT/', '30', '', 'Lưu chuyển tiền thuần từ hoạt động đầu tư', '  Net cash flow from financial investment', 1, '', 'Z(21+22+23+24+25+26+27)', '0.00', '0.00', '0.00', '0.00'),
(2720, 'DNL', '15', 'GT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2721, 'DNL', '15', 'GT*', '', '', 'III. Lưu chuyển tiền từ hoạt động tài chính', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2722, 'DNL', '15', 'GT', '31', '', '1.Tiền thu từ phát hành cổ phiếu, nhận vốn góp của chủ sở hữu', '', 1, '', '11/411', '0.00', '0.00', '0.00', '0.00'),
(2723, 'DNL', '15', 'GT', '32', '', '2.Tiền chi trả vốn góp cho các chủ sở hữu, mua lại cổ phiếu của DN đã phát hành', '', -1, '', '411/11', '0.00', '0.00', '0.00', '0.00'),
(2724, 'DNL', '15', 'GT', '33', '', '3. Tiền thu từ đi vay', '', 1, '', '11/311,341', '6263955163.00', '26784828837.00', '20493325959.00', '26784828837.00'),
(2725, 'DNL', '15', 'GT', '34', '', '4. Tiền trả nợ gốc vay', '', -1, '', '311,341/11', '-10119514698.00', '-45337026873.00', '-33059838221.00', '-45337026873.00'),
(2726, 'DNL', '15', 'GT', '35', '', '5. Tiền trả nợ thuê tài chính', '', -1, '', '342/11,311', '0.00', '0.00', '0.00', '0.00'),
(2727, 'DNL', '15', 'GT', '36', '', '6. Cổ tức, lợi nhuận đã trả cho chủ sở hữu', '', -1, '3388c', '3388c/11,311', '0.00', '0.00', '0.00', '0.00'),
(2728, 'DNL', '15', 'GT/', '40', '', 'Lưu chuyển tiền thuần từ hoạt động tài chính', '', 1, '', 'Z(31+32+33+34+35+36)', '-3855559535.00', '-18552198036.00', '-12566512262.00', '-18552198036.00'),
(2729, 'DNL', '15', 'GT*', '50', '', 'Lưu chuyển tiền thuần trong kỳ (50=20+30+40)', '', 1, '', 'Z(20+30+40)', '-142741585.00', '220019400.00', '-199367559.00', '220019400.00'),
(2730, 'DNL', '15', 'GT*', '60', '', 'Tiền và tương đương tiền đầu kỳ', '', 1, '', 'C-D 11', '378289448.00', '434915422.00', '434915422.00', '434915422.00'),
(2731, 'DNL', '15', 'GT', '61', '', 'Ảnh hưởng của thay đổi tỷ giá hối đoái quy đổi ngoại tệ', '', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2732, 'DNL', '15', 'GT*', '70', '', 'Tiền và tương đương tiền cuối kỳ (50+60+61)', '', 1, '', 'Z(50+60)', '235547863.00', '654934822.00', '235547863.00', '654934822.00'),
(2733, 'DNL', '15', 'TT*', '', '', 'I.Lưu chuyển tiền từ hoạt động kinh doanh', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2734, 'DNL', '15', 'TT', '01', '', '1. Tiền thu từ bán hàng, cung cấp dịch vụ và doanh thu khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2735, 'DNL', '15', 'TT', '02', '', '2. Tiền chi trả cho người cung cấp hàng hóa và dịch vụ', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2736, 'DNL', '15', 'TT', '03', '', '3. Tiền chi trả cho người lao động', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2737, 'DNL', '15', 'TT', '04', '', '4. Tiền lãi vay đã  trả', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2738, 'DNL', '15', 'TT', '05', '', '5. Thuế Thu nhập doanh nghiệp đã nộp', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2739, 'DNL', '15', 'TT', '06', '', '6. Tiền thu khác từ hoạt động kinh doanh', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2740, 'DNL', '15', 'TT', '07', '', '7. Tiền chi khác cho hoạt động kinh doanh', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2741, 'DNL', '15', 'TT/', '20', '', 'Lưu chuyển tiền thuần từ hoạt động kinh doanh', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2742, 'DNL', '15', 'TT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2743, 'DNL', '15', 'TT*', '', '', 'II. Lưu chuyển tiền từ hoạt động đầu tư', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2744, 'DNL', '15', 'TT', '21', '', '1.Tiền chi để mua sắm, xây dựng TSCĐ và các tài sản dài hạn khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2745, 'DNL', '15', 'TT', '22', '', '2.Tiền thu từ thanh lý, nhượng bán TSCĐ và các tài sản dài hạn khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2746, 'DNL', '15', 'TT', '23', '', '3. Tiền chi cho vay, mua các công cụ nợ của đơn vị khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2747, 'DNL', '15', 'TT', '24', '', '4.Tiền thu hồi cho vay, bán lại các công cụ nợ của đơn vị khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2748, 'DNL', '15', 'TT', '25', '', '5. Tiền chi đầu tư góp vốn vào đơn vị khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2749, 'DNL', '15', 'TT', '26', '', '6. Tiền thu hồi đầu tư góp vốn vào đơn vị khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2750, 'DNL', '15', 'TT', '27', '', '7. Tiền thu lãi cho vay, cổ tức và lợi nhuận được chia', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2751, 'DNL', '15', 'TT/', '30', '', 'Lưu chuyển tiền thuần từ hoạt động đầu tư', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2752, 'DNL', '15', 'TT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2753, 'DNL', '15', 'TT*', '', '', 'III. Lưu chuyển tiền từ hoạt động tài chính', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2754, 'DNL', '15', 'TT', '31', '', '1.Tiền thu từ phát hành cổ phiếu, nhận vốn góp của chủ sở hữu', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2755, 'DNL', '15', 'TT', '32', '', '2.Tiền chi trả vốn góp cho các chủ sở hữu, mua lại cổ phiếu của DN đã phát hành', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2756, 'DNL', '15', 'TT', '33', '', '3. Tiền thu từ đi vay', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2757, 'DNL', '15', 'TT', '34', '', '4. Tiền trả nợ gốc vay', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2758, 'DNL', '15', 'TT', '35', '', '5. Tiền trả nợ gốc thuê tài chính', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2759, 'DNL', '15', 'TT', '36', '', '6. Cổ tức, lợi nhuận đã trả cho chủ sở hữu', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2760, 'DNL', '15', 'TT/', '40', '', 'Lưu chuyển tiền thuần từ hoạt động tài chính', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2761, 'DNL', '15', 'TT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2762, 'DNL', '15', 'TT*', '50', '', 'Lưu chuyển tiền thuần trong kỳ (50=20+30+40)', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2763, 'DNL', '15', 'TT*', '60', '', 'Tiền và tương đương tiền đầu kỳ', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2764, 'DNL', '15', 'TT', '61', '', 'Ảnh hưởng của thay đổi tỷ giá hối đoái quy đổi ngoại tệ', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2765, 'DNL', '15', 'TT*', '70', '', 'Tiền và tương đương tiền cuối kỳ (50+60+61)', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2766, 'DNN', '04', 'GT*', '', '', 'I - LƯU CHUYÊN TIÊN TƯ HOAT ĐÔNG SXKD', 'I - CASH FLOW FROM PRODUCTION AND BUSINESS', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2767, 'DNN', '04', 'GT/', '01', '', '  Lợi nhuận trước thuế :', '  Profit before tax :', 1, '', '911/421', '0.00', '215951656.00', '0.00', '0.00'),
(2768, 'DNN', '04', 'GT/', '', '', '  Điều chỉnh cho các khoản :', '', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2769, 'DNN', '04', 'GT', '02', '', '    - Khấu hao tài sản cố định', '    - Fixed assets depreciation', -1, '', '6/214', '0.00', '-114301836.00', '0.00', '0.00'),
(2770, 'DNN', '04', 'GT', '03', '', '    - Các khoản dự phòng', '    - Reserves', -1, '', 'C-D 129,139,159,129,229', '0.00', '0.00', '0.00', '0.00'),
(2771, 'DNN', '04', 'GT', '04', '', '    - Lãi ,lổ do bán TSCĐ', '    - Surplus or loss from fixed assets sale', -1, '42121', '911/42121', '0.00', '0.00', '0.00', '0.00'),
(2772, 'DNN', '04', 'GT', '05', '', '    - Lãi ,lổ do đánh giá lại TS ,đổi tiền tệ', '    - Surplus or loss from fixed assets revalua', -1, '42123', '911/42123', '0.00', '0.00', '0.00', '0.00'),
(2773, 'DNN', '04', 'GT', '06', '', '    - Lãi do đầu tư vào các đơn vị khác', '    - Benifit from financial investment', -1, '42122', '911/42122', '0.00', '0.00', '0.00', '0.00'),
(2774, 'DNN', '04', 'GT', '07', '', '    - Thu lãi tiền gửi', '    - Interest earnings', -1, '7112', '11/7112', '0.00', '0.00', '0.00', '0.00'),
(2775, 'DNN', '04', 'GT/', '10', '', ' 3. Lợi nhuận k/doanh trước thay đổi vốn lưu độ', ' 3. Business profit by working capital changes', 1, '', 'Z(01+02+03+04+05+06+07)', '0.00', '101649820.00', '0.00', '0.00'),
(2776, 'DNN', '04', 'GT', '11', '', '    - Tăng giảm các khoản phải thu', '    - Increase or decrease of receivables', -1, '', 'C-D 131,136,138,141,142,144', '0.00', '-2150648847.00', '0.00', '0.00'),
(2777, 'DNN', '04', 'GT', '12', '', '    - Tăng giảm hàng tồn kho', '    - Increase or decrease of inventories', -1, '', 'C-D 151,152,153,154,155,156,157', '0.00', '1371560405.00', '0.00', '0.00'),
(2778, 'DNN', '04', 'GT', '13', '', '    - Tăng giảm các khoản phải trả', '    - Increase or decrease of payables', -1, '', 'C-D 315,331,333,334,335,336,338', '0.00', '11454924479.00', '0.00', '0.00'),
(2779, 'DNN', '04', 'GT', '14', '', '    - Tiền thu từ các khoản khác', '    - Other receipts', 1, '', '', '0.00', '2117165141.00', '0.00', '0.00'),
(2780, 'DNN', '04', 'GT', '15', '', '    - Tiền chi cho các khoản khác', '    - Other payments', -1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2781, 'DNN', '04', 'GT/', '20', '', '  Lưu chuyển tiền tệ thuần từ hoạt động SXKD', '  Net cash flow from production and business', 1, '', 'Z(10+11+12+13+14+15)', '0.00', '12894650998.00', '0.00', '0.00'),
(2782, 'DNN', '04', 'GT*', '', '', 'II - LƯU CHUYÊN TIÊN TƯ HOAT ĐÔNG ĐÂU TƯ', 'II - CASH FLOW FROM FINANCIAL INVESTMENT', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2783, 'DNN', '04', 'GT', '21', '', '    - Tiền thu hồi các khoản đ.tư vào đ.vị khác', '    - Returns from other invested units', 1, '', '11/121,128,221,222,228', '0.00', '10000000.00', '0.00', '0.00'),
(2784, 'DNN', '04', 'GT', '22', '', '    - Tiền thu từ lãi khoản đ.tư vào đ.vị khác', '    - Investment benifits from invested units', 1, '7111', '11/7111', '0.00', '0.00', '0.00', '0.00'),
(2785, 'DNN', '04', 'GT', '23', '', '    - Tiền thu do bán tài sản cố định', '    - Receipts from fixed assets sale', 1, '7211', '11/7211', '0.00', '0.00', '0.00', '0.00'),
(2786, 'DNN', '04', 'GT', '24', '', '    - Tiền đầu tư vào các đơn vị khác', '    - Financial investment on other units', -1, '', '121,128,221,222,228/11', '0.00', '0.00', '0.00', '0.00'),
(2787, 'DNN', '04', 'GT', '25', '', '    - Tiền mua tài sản cố định', '    - Fixed assets purchases', -1, '', '211,212,213/11', '0.00', '-7595800.00', '0.00', '0.00'),
(2788, 'DNN', '04', 'GT/', '30', '', '  Lưu chuyển tiền tệ thuần từ hoạt động đầu tư', '  Net cash flow from financial investment', 1, '', 'Z(21+22+23+24+25)', '0.00', '2404200.00', '0.00', '0.00'),
(2789, 'DNN', '04', 'GT*', '', '', 'III - LƯU CHUYÊN TIÊN TƯ HOAT ĐÔNG TAI CHINH', 'III - CASH FLOW FROM FINANCIAL ACTIVITIES', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2790, 'DNN', '04', 'GT', '31', '', '    - Tiền thu do đi vay', '    - Receipts from borrowings', 1, '', '11/311,341,342', '0.00', '3068061223.00', '0.00', '0.00'),
(2791, 'DNN', '04', 'GT', '32', '', '    - Tiền thu do các chủ sở hữu góp vốn', '    - Receipts from owner`s equity', 1, '', '11/411', '0.00', '0.00', '0.00', '0.00'),
(2792, 'DNN', '04', 'GT', '33', '', '    - Tiền thu từ lãi tiền gửi', '    - Interest earnings', 1, '7112', '11/7112', '0.00', '0.00', '0.00', '0.00'),
(2793, 'DNN', '04', 'GT', '34', '', '    - Tiền đã trả nợ vay', '    - Paid debt services', -1, '', '311,341,342/11', '0.00', '-15713797000.00', '0.00', '0.00'),
(2794, 'DNN', '04', 'GT', '35', '', '    - Tiền đã hoàn vốn cho các chủ sở hữu', '    - Return to owners', -1, '33381', '411,33381/11', '0.00', '0.00', '0.00', '0.00'),
(2795, 'DNN', '04', 'GT', '36', '', '    - Tiền lãi đã trả cho các nhà đ.tư vào DN', '    - Interest paid to investors', -1, '7111', '7111,431/11', '0.00', '-8919000.00', '0.00', '0.00'),
(2796, 'DNN', '04', 'GT/', '40', '', '  Lưu chuyển tiền tệ thuần từ h/động tài chính', '  Net cash flow from financial activities', 1, '', 'Z(31+32+33+34+35+36)', '0.00', '-12654654777.00', '0.00', '0.00'),
(2797, 'DNN', '04', 'GT*', '50', '', '  Lưu chuyển tiền tệ thuần trong kỳ', '  Net cash flow in current period', 1, '', 'Z(20+30+40)', '0.00', '242400421.00', '0.00', '0.00'),
(2798, 'DNN', '04', 'GT*', '60', '', '  Tiền tồn đầu kỳ', '  Opening period balance', 1, '', 'C-D 11', '322448721.00', '322448721.00', '0.00', '0.00'),
(2799, 'DNN', '04', 'GT*', '70', '', '  Tiền tồn cuối kỳ', '  Closing period balance', 1, '', 'Z(50+60)', '322448721.00', '564849142.00', '0.00', '0.00'),
(2800, 'DNN', '04', '---', '--', '', '-----------------------------------------------', '-----------------------------------------------', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2801, 'DNN', '04', 'TT*', '', '', 'I - LƯU CHUYÊN TIÊN TƯ HOAT ĐÔNG SXKD', 'I - CASH FLOW FROM PRODUCTION AND BUSINESS', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2802, 'DNN', '04', 'TT', '01', '', '  1. Tiền thu bán hàng', '  1. Sale turnover', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2803, 'DNN', '04', 'TT', '02', '', '  2. Tiền thu từ các khoản nợ phải thu', '  2. Receipts from receivable loans', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2804, 'DNN', '04', 'TT', '03', '', '  3. Tiền thu từ các khoản khác', '  3. Other receipts', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2805, 'DNN', '04', 'TT', '04', '', '  4. Tiền đã trả cho người bán', '  4. Paid payment to sellers', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2806, 'DNN', '04', 'TT/', '05', '', '  5. Tiền đã trả cho công nhân viên', '  5. Paid payment to employees', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2807, 'DNN', '04', 'TT', '06', '', '  6. Tiền đã nộp thuế và các khoản khác cho NN', '  6. Tax and other contributions to goverment', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2808, 'DNN', '04', 'TT', '07', '', '  7. Tiền đã trả cho các khoản nợ phải trả khác', '  7. Payment paid to payable debts', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2809, 'DNN', '04', 'TT', '08', '', '  8. Tiền đã trả cho các khoản khác', '  8. Other paid payments', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2810, 'DNN', '04', 'TT/', '20', '', '  Lưu chuyển tiền tệ thuần từ hoạt động SXKD', '  Net cash flow from production and business', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2811, 'DNN', '04', 'TT*', '', '', 'II - LƯU CHUYÊN TIÊN TƯ HOAT ĐÔNG ĐÂU TƯ', 'II - CASH FLOW FROM FINANCIAL INVESTMENT', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2812, 'DNN', '04', 'TT', '21', '', '  1. Tiền thu hồi các khoản đầu tư vào đv khác', '  1. Return from other invested units', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2813, 'DNN', '04', 'TT', '22', '', '  2. Tiền thu từ lãi các khoản đ.tư vào đv khác', '  2. interest from invested units', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2814, 'DNN', '04', 'TT', '23', '', '  3. Tiền thu do bán tài sản cố định', '  3. Receipts from fixed assets sale', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2815, 'DNN', '04', 'TT', '24', '', '  4. Tiền đầu tư vào đơn vị khác', '  4. Financial investment on others', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2816, 'DNN', '04', 'TT', '25', '', '  5. Tiền mua tài sản cố định', '  5. Fixed assets purchases', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2817, 'DNN', '04', 'TT/', '30', '', '  Lưu chuyển tiền tệ thuần từ hoạt động đầu tư', '  Net cash flow from financial investment', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2818, 'DNN', '04', 'TT*', '', '', 'III - LƯU CHUYÊN TIÊN TƯ HOAT ĐÔNG TAI CHINH', 'III - CASH FLOW FROM FINANCIAL ACTIVITIES', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2819, 'DNN', '04', 'TT', '31', '', '  1. Tiền thu do đi vay', '  1. Receipts from borrowings', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2820, 'DNN', '04', 'TT', '32', '', '  2. Tiền thu do các chủ sở hữu góp vốn', '  2. Receipts from owner`s equity', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2821, 'DNN', '04', 'TT', '33', '', '  3. Tiền thu từ lãi tiền gửi', '  3. Interest earnings', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2822, 'DNN', '04', 'TT', '34', '', '  4. Tiền đã trả nợ vay', '  4. Paid payment of debt', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2823, 'DNN', '04', 'TT', '35', '', '  5. Tiền đã hoàn vốn cho các chủ sở hữu', '  5. Returns to owners', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2824, 'DNN', '04', 'TT', '36', '', '  6. Tiền lãi đã trả cho các nhà đầu tư vào DN', '  6. Interest paid to investors', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2825, 'DNN', '04', 'TT/', '40', '', '  Lưu chuyển tiền tệ thuần từ h/động tài chính', '  Net cash flow from financial activity', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2826, 'DNN', '04', 'TT*', '50', '', '  Lưu chuyển tiền thuần trong kỳ', '  Net cash flow in current period', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2827, 'DNN', '04', 'TT*', '60', '', '  Tiền tồn đầu kỳ', '  Opening period balance', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2828, 'DNN', '04', 'TT*', '70', '', '  Tiền tồn cuối kỳ', '  Closing period balance', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2829, 'DNN', '05', 'GT*', '', '', 'I. Lưu chuyển tiền từ hoạt động kinh doanh', '', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2830, 'DNN', '05', 'GT*', '01', '', '1. Lợi nhuận trước thuế', '  Profit before tax :', 1, '', '911/421,821', '273231268.00', '1292809425.00', '864585101.00', '1292809425.00'),
(2831, 'DNN', '05', 'GT*', '', '', '2. Điều chỉnh cho các khoản', '', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2832, 'DNN', '05', 'GT', '02', '', '    - Khấu hao TSCĐ', '    - Fixed assets depreciation', -1, '', '6/214', '-487315262.00', '-1977584621.00', '-1429215868.00', '-1977584621.00'),
(2833, 'DNN', '05', 'GT', '03', '', '    - Các khoản dự phòng', '    - Reserves', -1, '', 'C-D 129,139,159,229', '0.00', '111226000.00', '0.00', '111226000.00'),
(2834, 'DNN', '05', 'GT', '04', '', '    - Lãi, lổ chênh lệch tỷ giá hối đoái chưa thực hiện', '', -1, '42121', '911/42121', '0.00', '0.00', '0.00', '0.00'),
(2835, 'DNN', '05', 'GT', '05', '', '    - Lãi, lổ từ hoạt động đầu tư', '', -1, '42122', '911/42122', '0.00', '0.00', '0.00', '0.00'),
(2836, 'DNN', '05', 'GT', '06', '', '    - Chi phí lãi vay', '', -1, '635v', '635v/311,11', '0.00', '0.00', '0.00', '0.00'),
(2837, 'DNN', '05', 'GT*', '08', '', '3. Lợi nhuận từ hoạt động kinh doanh trước thay đổi vốn  lưu động', ' 3. Business profit by working capital changes', 1, '', 'Z(01+02+03+04+05+06)', '-214083994.00', '-573549196.00', '-564630767.00', '-573549196.00'),
(2838, 'DNN', '05', 'GT', '09', '', '    - Tăng giảm các khoản phải thu', '    - Increase or decrease of receivables', -1, '', 'C-D 131,136,138,141,144', '-76960754.00', '8679720.00', '-2037250186.00', '8679720.00'),
(2839, 'DNN', '05', 'GT', '10', '', '    - Tăng giảm hàng tồn kho', '    - Increase or decrease of inventories', -1, '', 'C-D 151,152,153,154,155,156,157', '491685864.00', '-646793757.00', '1491318047.00', '-646793757.00'),
(2840, 'DNN', '05', 'GT', '11', '', '    - Tăng giảm các khoản phải trả (không kể lãi vay phải trả, thuế TN phải nộp)', '    - Increase or decrease of payables', -1, '', 'C-D 315,331,333,334,335,336,337,338', '1103689522.00', '-330664175.00', '-84596969.00', '-330664175.00'),
(2841, 'DNN', '05', 'GT', '12', '', '    - Tăng giảm chi phí trả trước', '', -1, '', 'C-D 142,242', '98247506.00', '134247506.00', '134247506.00', '134247506.00'),
(2842, 'DNN', '05', 'GT', '13', '', '    - Tiền lãi vay đã trả', '', -1, '335v', '335v/11,311', '0.00', '0.00', '0.00', '0.00'),
(2843, 'DNN', '05', 'GT', '14', '', '    - Thuế thu nhập doanh nghiệp đã nộp', '', -1, '', '3334/11,311', '0.00', '-12264061.00', '-12264061.00', '-12264061.00'),
(2844, 'DNN', '05', 'GT', '15', '', '    - Tiền thu khác từ hoạt động kinh doanh', '', 1, '', '', '2096155812.00', '19619012203.00', '12875690366.00', '19619012203.00'),
(2845, 'DNN', '05', 'GT', '16', '', '    - Tiền chi khác từ hoạt động kinh doanh', '', -1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2846, 'DNN', '05', 'GT/', '20', '', 'Lưu chuyển tiền thuần từ hoạt động kinh doanh', '  Net cash flow from production and business', 1, '', 'Z(08+09+10+11+12+13+14+15+16)', '3712817950.00', '18772217436.00', '12367144703.00', '18772217436.00'),
(2847, 'DNN', '05', 'GT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2848, 'DNN', '05', 'GT*', '', '', 'II. Lưu chuyển tiền từ hoạt động đầu tư', 'II - CASH FLOW FROM FINANCIAL INVESTMENT', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2849, 'DNN', '05', 'GT', '21', '', '1.Tiền chi để mua sắm, xây dựng TSCĐ và các tài sản dài hạn khác', '    - Fixed assets purchases', -1, '', '211,212,213,217/11,311', '0.00', '0.00', '0.00', '0.00'),
(2850, 'DNN', '05', 'GT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2851, 'DNN', '05', 'GT', '22', '', '2.Tiền thu từ thanh lý, nhượng bán TSCĐ và các tài sản dài hạn khác', '    - Receipts from fixed assets sale', 1, '7112', '11/7112', '0.00', '0.00', '0.00', '0.00'),
(2852, 'DNN', '05', 'GT', '23', '', '3.Tiền chi cho vay, mua các công cụ nợ của đơn vị khác', '', -1, '1388v', '1388v/11', '0.00', '0.00', '0.00', '0.00'),
(2853, 'DNN', '05', 'GT', '24', '', '4.Tiền thu hồi cho vay, bán lại các công cụ nợ của đơn vị khác', '', 1, '1388v', '11/1388v', '0.00', '0.00', '0.00', '0.00'),
(2854, 'DNN', '05', 'GT', '25', '', '5. Tiền chi đầu tư góp vốn vào đơn vị khác', '', -1, '', '121,128,221,222,228/11,311', '0.00', '0.00', '0.00', '0.00'),
(2855, 'DNN', '05', 'GT', '26', '', '6. Tiền thu hồi đầu tư góp vốn vào đơn vị khác', '    - Returns from other invested units', 1, '', '11/121,128,221,222,228', '0.00', '0.00', '0.00', '0.00'),
(2856, 'DNN', '05', 'GT', '27', '', '7. Tiền thu lãi cho vay, cổ tức và lợi nhuận được chia', '', 1, '7113', '11/7113', '0.00', '0.00', '0.00', '0.00'),
(2857, 'DNN', '05', 'GT/', '30', '', 'Lưu chuyển tiền thuần từ hoạt động đầu tư', '  Net cash flow from financial investment', 1, '', 'Z(21+22+23+24+25+26+27)', '0.00', '0.00', '0.00', '0.00'),
(2858, 'DNN', '05', 'GT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2859, 'DNN', '05', 'GT*', '', '', 'III. Lưu chuyển tiền từ hoạt động tài chính', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2860, 'DNN', '05', 'GT', '31', '', '1.Tiền thu từ phát hành cổ phiếu, nhận vốn góp của chủ sở hữu', '', 1, '', '11/411', '0.00', '0.00', '0.00', '0.00'),
(2861, 'DNN', '05', 'GT', '32', '', '2.Tiền chi trả vốn góp cho các chủ sở hữu, mua lại cổ phiếu của DN đã phát hành', '', -1, '', '411/11', '0.00', '0.00', '0.00', '0.00'),
(2862, 'DNN', '05', 'GT', '33', '', '3. Tiền vay ngắn hạn, dài hạn nhận được', '', 1, '', '11/311,341', '6263955163.00', '26784828837.00', '20493325959.00', '26784828837.00'),
(2863, 'DNN', '05', 'GT', '34', '', '4. Tiền chi trả nợ gốc vay', '', -1, '', '311,341/11', '-10119514698.00', '-45337026873.00', '-33059838221.00', '-45337026873.00'),
(2864, 'DNN', '05', 'GT', '35', '', '5. Tiền chi trả nợ thuê tài chính', '', -1, '', '342/11,311', '0.00', '0.00', '0.00', '0.00'),
(2865, 'DNN', '05', 'GT', '36', '', '6. Cổ tức, lợi nhuận đã trả cho chủ sở hữu', '', -1, '3388c', '3388c/11,311', '0.00', '0.00', '0.00', '0.00'),
(2866, 'DNN', '05', 'GT/', '40', '', 'Lưu chuyển tiền thuần từ hoạt động tài chính', '', 1, '', 'Z(31+32+33+34+35+36)', '-3855559535.00', '-18552198036.00', '-12566512262.00', '-18552198036.00'),
(2867, 'DNN', '05', 'GT*', '50', '', 'Lưu chuyển tiền thuần trong kỳ (50=20+30+40)', '', 1, '', 'Z(20+30+40)', '-142741585.00', '220019400.00', '-199367559.00', '220019400.00'),
(2868, 'DNN', '05', 'GT*', '60', '', 'Tiền và tương đương tiền đầu kỳ', '', 1, '', 'C-D 11', '378289448.00', '434915422.00', '434915422.00', '434915422.00');
INSERT INTO `lctiente` (`id`, `chedokt`, `kyhieu`, `swt`, `maso`, `tminh`, `chitieu`, `chitieuu`, `dau`, `tkmoi`, `cachtinh`, `kytruoc`, `kynay`, `kytruoclk`, `kynaylk`) VALUES
(2869, 'DNN', '05', 'GT', '61', '', 'Ảnh hưởng của thay đổi tỷ giá hối đoái quy đổi ngoại tệ', '', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2870, 'DNN', '05', 'GT*', '70', 'VI.31', 'Tiền và tương đương tiền cuối kỳ (50+60+61)', '', 1, '', 'Z(50+60)', '235547863.00', '654934822.00', '235547863.00', '654934822.00'),
(2871, 'DNN', '05', 'TT*', '', '', 'I.Lưu chuyển tiền thuần từ hoạt động kinh doanh', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2872, 'DNN', '05', 'TT', '01', '', '1. Tiền thu từ bán hàng, cung cấp dịch vụ và doanh thu khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2873, 'DNN', '05', 'TT', '02', '', '2. Tiền chi trả cho người cung cấp hàng hóa và dịch vụ', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2874, 'DNN', '05', 'TT', '03', '', '3. Tiền chi trả cho người lao động', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2875, 'DNN', '05', 'TT', '04', '', '4. Tiền chi trả lãi vay', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2876, 'DNN', '05', 'TT', '05', '', '5. Tiền chi nộp thuế Thu nhập doanh nghiệp', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2877, 'DNN', '05', 'TT', '06', '', '6. Tiền thu khác từ hoạt động kinh doanh', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2878, 'DNN', '05', 'TT', '07', '', '7. Tiền chi khác cho hoạt động kinh doanh', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2879, 'DNN', '05', 'TT/', '20', '', 'Lưu chuyển tiền thuần từ hoạt động kinh doanh', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2880, 'DNN', '05', 'TT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2881, 'DNN', '05', 'TT*', '', '', 'II. Lưu chuyển tiền từ hoạt động đầu tư', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2882, 'DNN', '05', 'TT', '21', '', '1.Tiền chi để mua sắm, xây dựng TSCĐ và các tài sản dài hạn khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2883, 'DNN', '05', 'TT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2884, 'DNN', '05', 'TT', '22', '', '2.Tiền thu từ thanh lý, nhượng bán TSCĐ và các tài sản dài hạn khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2885, 'DNN', '05', 'TT', '23', '', '3. Tiền chi cho vay, mua các công cụ nợ của đơn vị khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2886, 'DNN', '05', 'TT', '24', '', '4.Tiền thu hồi cho vay, bán lại các công cụ nợ của đơn vị khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2887, 'DNN', '05', 'TT', '25', '', '5. Tiền chi đầu tư góp vốn vào đơn vị khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2888, 'DNN', '05', 'TT', '26', '', '6. Tiền thu hồi đầu tư góp vốn vào đơn vị khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2889, 'DNN', '05', 'TT', '27', '', '7. Tiền thu lãi cho vay, cổ tức và lợi nhuận được chia', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2890, 'DNN', '05', 'TT/', '30', '', 'Lưu chuyển tiền thuần từ hoạt động đầu tư', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2891, 'DNN', '05', 'TT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2892, 'DNN', '05', 'TT*', '', '', 'III. Lưu chuyển tiền từ hoạt động tài chính', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2893, 'DNN', '05', 'TT', '31', '', '1.Tiền thu từ phát hành cổ phiếu, nhận vốn góp của chủ sở hữu', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2894, 'DNN', '05', 'TT', '32', '', '2.Tiền chi trả vốn góp cho các chủ sở hữu, mua lại cổ phiếu của DN đã phát hành', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2895, 'DNN', '05', 'TT', '33', '', '3. Tiền vay ngắn hạn, dài hạn nhận được', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2896, 'DNN', '05', 'TT', '34', '', '4. Tiền chi trả nợ gốc vay', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2897, 'DNN', '05', 'TT', '35', '', '5. Tiền chi trả nợ thuê tài chính', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2898, 'DNN', '05', 'TT', '36', '', '6. Cổ tức, lợi nhuận đã trả cho chủ sở hữu', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2899, 'DNN', '05', 'TT/', '40', '', 'Lưu chuyển tiền thuần từ hoạt động tài chính', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2900, 'DNN', '05', 'TT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2901, 'DNN', '05', 'TT*', '50', '', 'Lưu chuyển tiền thuần trong kỳ (50=20+30+40)', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2902, 'DNN', '05', 'TT*', '60', '', 'Tiền và tương đương tiền đầu kỳ', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2903, 'DNN', '05', 'TT', '61', '', 'Ảnh hưởng của thay đổi tỷ giá hối đoái quy đổi ngoại tệ', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2904, 'DNN', '05', 'TT*', '70', 'VII34', 'Tiền và tương đương tiền cuối kỳ (50+60+61)', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2905, 'DNN', '15', 'GT*', '', '', 'I. Lưu chuyển tiền từ hoạt động kinh doanh', '', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2906, 'DNN', '15', 'GT*', '01', '', '1. Lợi nhuận trước thuế', '  Profit before tax :', 1, '', '911/421,821', '273231268.00', '1292809425.00', '864585101.00', '1292809425.00'),
(2907, 'DNN', '15', 'GT*', '02', '', '2. Điều chỉnh cho các khoản', '', -1, '', 'Z(03+04+05+06+07+08)', '0.00', '0.00', '0.00', '0.00'),
(2908, 'DNN', '15', 'GT', '03', '', '    - Khấu hao TSCĐ và BĐSĐT', '    - Fixed assets depreciation', -1, '', '6/214', '-487315262.00', '-1977584621.00', '-1429215868.00', '-1977584621.00'),
(2909, 'DNN', '15', 'GT', '04', '', '    - Các khoản dự phòng', '    - Reserves', -1, '', 'C-D 129,139,159,229', '0.00', '111226000.00', '0.00', '111226000.00'),
(2910, 'DNN', '15', 'GT', '05', '', '    - Lãi, lổ chênh lệch tỷ giá hối đoái  do đánh giá lại các khoản mục  ngoại tệ', '', -1, '42121', '911/42121', '0.00', '0.00', '0.00', '0.00'),
(2911, 'DNN', '15', 'GT', '06', '', '    - Lãi, lổ từ hoạt động đầu tư', '', -1, '42122', '911/42122', '0.00', '0.00', '0.00', '0.00'),
(2912, 'DNN', '15', 'GT', '07', '', '    - Chi phí lãi vay', '', -1, '635v', '635v/311,11,3411', '0.00', '0.00', '0.00', '0.00'),
(2913, 'DNN', '15', 'GT', '08', '', '    - Các khoản điều chỉnh khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2914, 'DNN', '15', 'GT*', '09', '', '3. Lợi nhuận từ hoạt động kinh doanh trước thay đổi vốn  lưu động', ' 3. Business profit by working capital changes', 1, '', 'Z(01+03+04+05+06+07+08)', '-214083994.00', '-573549196.00', '-564630767.00', '-573549196.00'),
(2915, 'DNN', '15', 'GT', '10', '', '    - Tăng giảm các khoản phải thu', '    - Increase or decrease of receivables', -1, '', 'C-D 131,136,138,141,144', '-76960754.00', '8679720.00', '-2037250186.00', '8679720.00'),
(2916, 'DNN', '15', 'GT', '11', '', '    - Tăng giảm hàng tồn kho', '    - Increase or decrease of inventories', -1, '', 'C-D 151,152,153,154,155,156,157', '491685864.00', '-646793757.00', '1491318047.00', '-646793757.00'),
(2917, 'DNN', '15', 'GT', '12', '', '    - Tăng giảm các khoản phải trả (không kể lãi vay phải trả, thuế TN phải nộp)', '    - Increase or decrease of payables', -1, '', 'C-D 315,331,333,334,335,336,337,338', '1103689522.00', '-330664175.00', '-84596969.00', '-330664175.00'),
(2918, 'DNN', '15', 'GT', '13', '', '    - Tăng giảm chi phí trả trước', '', -1, '', 'C-D 142,242', '98247506.00', '134247506.00', '134247506.00', '134247506.00'),
(2919, 'DNN', '15', 'GT', '14', '', '    - Tăng giảm chứng khoán kinh doanh', '', -1, '', 'C-D 121', '0.00', '0.00', '0.00', '0.00'),
(2920, 'DNN', '15', 'GT', '15', '', '    - Tiền lãi vay đã trả', '', -1, '335v', '335v/11,311,3411', '0.00', '0.00', '0.00', '0.00'),
(2921, 'DNN', '15', 'GT', '16', '', '    - Thuế thu nhập doanh nghiệp đã nộp', '', -1, '', '3334/11,311,3411', '0.00', '-12264061.00', '-12264061.00', '-12264061.00'),
(2922, 'DNN', '15', 'GT', '17', '', '    - Tiền thu khác từ hoạt động kinh doanh', '', 1, '', '', '2096155812.00', '19619012203.00', '12875690366.00', '19619012203.00'),
(2923, 'DNN', '15', 'GT', '18', '', '    - Tiền chi khác từ hoạt động kinh doanh', '', -1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2924, 'DNN', '15', 'GT/', '20', '', 'Lưu chuyển tiền thuần từ hoạt động kinh doanh', '  Net cash flow from production and business', 1, '', 'Z(09+10+11+12+13+14+15+16+17+18)', '3712817950.00', '18772217436.00', '12367144703.00', '18772217436.00'),
(2925, 'DNN', '15', 'GT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2926, 'DNN', '15', 'GT*', '', '', 'II. Lưu chuyển tiền từ hoạt động đầu tư', 'II - CASH FLOW FROM FINANCIAL INVESTMENT', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2927, 'DNN', '15', 'GT', '21', '', '1.Tiền chi để mua sắm, xây dựng TSCĐ ,BĐSĐT và các tài sản dài hạn khác', '    - Fixed assets purchases', -1, '', '211,212,213,217/11,311,3411', '0.00', '0.00', '0.00', '0.00'),
(2928, 'DNN', '15', 'GT', '22', '', '2.Tiền thu từ thanh lý, nhượng bán TSCĐ ,BĐSĐT và các tài sản dài hạn khác', '    - Receipts from fixed assets sale', 1, '7112', '11/7112', '0.00', '0.00', '0.00', '0.00'),
(2929, 'DNN', '15', 'GT', '23', '', '3.Tiền chi cho vay, đầu tư góp vốn vào đơn vị khác', '', -1, '1388v', '1388v,121,128,221,222,228/11,311,34', '0.00', '0.00', '0.00', '0.00'),
(2930, 'DNN', '15', 'GT', '24', '', '4.Tiền thu hồi cho vay, đầu tư góp vốn vào đơn vị khác', '', 1, '1388v', '11/1388v,121,128,221,222,228', '0.00', '0.00', '0.00', '0.00'),
(2931, 'DNN', '15', 'GT', '25', '', '5. Tiền thu lãi cho vay, cổ tức và lợi nhuận được chia', '', 1, '7113', '11/7113', '0.00', '0.00', '0.00', '0.00'),
(2932, 'DNN', '15', 'GT/', '30', '', 'Lưu chuyển tiền thuần từ hoạt động đầu tư', '  Net cash flow from financial investment', 1, '', 'Z(21+22+23+24+25)', '0.00', '0.00', '0.00', '0.00'),
(2933, 'DNN', '15', 'GT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2934, 'DNN', '15', 'GT*', '', '', 'III. Lưu chuyển tiền từ hoạt động tài chính', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2935, 'DNN', '15', 'GT', '31', '', '1.Tiền thu từ phát hành cổ phiếu, nhận vốn góp của chủ sở hữu', '', 1, '', '11/411', '0.00', '0.00', '0.00', '0.00'),
(2936, 'DNN', '15', 'GT', '32', '', '2.Tiền chi trả vốn góp cho các chủ sở hữu, mua lại cổ phiếu của DN đã phát hành', '', -1, '', '411/11,311,3411', '0.00', '0.00', '0.00', '0.00'),
(2937, 'DNN', '15', 'GT', '33', '', '3. Tiền thu từ đi vay', '', 1, '', '11/311,341', '6263955163.00', '26784828837.00', '20493325959.00', '26784828837.00'),
(2938, 'DNN', '15', 'GT', '34', '', '4. Tiền trả nợ gốc vay và nợ thuê tài chính', '', -1, '', '311,341,342/11', '-10119514698.00', '-45337026873.00', '-33059838221.00', '-45337026873.00'),
(2939, 'DNN', '15', 'GT', '35', '', '5. Cổ tức, lợi nhuận đã trả cho chủ sở hữu', '', -1, '3388c', '3388c/11,311,3411', '0.00', '0.00', '0.00', '0.00'),
(2940, 'DNN', '15', 'GT/', '40', '', 'Lưu chuyển tiền thuần từ hoạt động tài chính', '', 1, '', 'Z(31+32+33+34+35)', '-3855559535.00', '-18552198036.00', '-12566512262.00', '-18552198036.00'),
(2941, 'DNN', '15', 'GT*', '50', '', 'Lưu chuyển tiền thuần trong  kỳ ( 50 = 20+30+40 )', '', 1, '', 'Z(20+30+40)', '-142741585.00', '220019400.00', '-199367559.00', '220019400.00'),
(2942, 'DNN', '15', 'GT*', '60', '', 'Tiền và tương đương tiền đầu kỳ', '', 1, '', 'C-D 11', '378289448.00', '434915422.00', '434915422.00', '434915422.00'),
(2943, 'DNN', '15', 'GT', '61', '', 'Ảnh hưởng của thay đổi tỷ giá hối đoái quy đổi ngoại tệ', '', 1, '', '', '0.00', '0.00', '0.00', '0.00'),
(2944, 'DNN', '15', 'GT*', '70', '', 'Tiền và tương đương tiền cuối kỳ (50+60+61)', '', 1, '', 'Z(50+60+61)', '235547863.00', '654934822.00', '235547863.00', '654934822.00'),
(2945, 'DNN', '15', 'TT*', '', '', 'I.Lưu chuyển tiền từ hoạt động kinh doanh', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2946, 'DNN', '15', 'TT', '01', '', '1. Tiền thu từ bán hàng, cung cấp dịch vụ và doanh thu khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2947, 'DNN', '15', 'TT', '02', '', '2. Tiền chi trả cho người cung cấp hàng hóa và dịch vụ', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2948, 'DNN', '15', 'TT', '03', '', '3. Tiền chi trả cho người lao động', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2949, 'DNN', '15', 'TT', '04', '', '4. Tiền lãi vay đã  trả', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2950, 'DNN', '15', 'TT', '05', '', '5. Thuế Thu nhập doanh nghiệp đã nộp', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2951, 'DNN', '15', 'TT', '06', '', '6. Tiền thu khác từ hoạt động kinh doanh', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2952, 'DNN', '15', 'TT', '07', '', '7. Tiền chi khác cho hoạt động kinh doanh', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2953, 'DNN', '15', 'TT/', '20', '', 'Lưu chuyển tiền thuần từ hoạt động kinh doanh', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2954, 'DNN', '15', 'TT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2955, 'DNN', '15', 'TT*', '', '', 'II. Lưu chuyển tiền từ hoạt động đầu tư', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2956, 'DNN', '15', 'TT', '21', '', '1.Tiền chi để mua sắm, xây dựng TSCĐ ,BĐSĐT và các tài sản dài hạn khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2957, 'DNN', '15', 'TT', '22', '', '2.Tiền thu từ thanh lý, nhượng bán TSCĐ ,BĐSĐT và các tài sản dài hạn khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2958, 'DNN', '15', 'TT', '23', '', '3. Tiền chi cho vay, đầu tư góp vốn vào đơn vị khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2959, 'DNN', '15', 'TT', '24', '', '4.Tiền thu hồi cho vay, đầu tư góp vốn vào đơn vị khác', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2960, 'DNN', '15', 'TT', '25', '', '5. Tiền thu lãi cho vay, cổ tức và lợi nhuận được chia', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2961, 'DNN', '15', 'TT/', '30', '', 'Lưu chuyển tiền thuần từ hoạt động đầu tư', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2962, 'DNN', '15', 'TT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2963, 'DNN', '15', 'TT*', '', '', 'III. Lưu chuyển tiền từ hoạt động tài chính', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2964, 'DNN', '15', 'TT', '31', '', '1.Tiền thu từ phát hành cổ phiếu, nhận vốn góp của chủ sở hữu', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2965, 'DNN', '15', 'TT', '32', '', '2.Tiền chi trả vốn góp cho các chủ sở hữu, mua lại cổ phiếu của DN đã phát hành', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2966, 'DNN', '15', 'TT', '33', '', '3. Tiền thu từ đi vay', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2967, 'DNN', '15', 'TT', '34', '', '4. Tiền trả nợ gốc vay', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2968, 'DNN', '15', 'TT', '35', '', '5. Tiền trả nợ gốc thuê tài chính', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2969, 'DNN', '15', 'TT', '36', '', '6. Cổ tức, lợi nhuận đã trả cho chủ sở hữu', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2970, 'DNN', '15', 'TT/', '40', '', 'Lưu chuyển tiền thuần từ hoạt động tài chính', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2971, 'DNN', '15', 'TT', '', '', '', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2972, 'DNN', '15', 'TT*', '50', '', 'Lưu chuyển tiền thuần trong kỳ (50=20+30+40)', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2973, 'DNN', '15', 'TT*', '60', '', 'Tiền và tương đương tiền đầu kỳ', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2974, 'DNN', '15', 'TT', '61', '', 'Ảnh hưởng của thay đổi tỷ giá hối đoái quy đổi ngoại tệ', '', 0, '', '', '0.00', '0.00', '0.00', '0.00'),
(2975, 'DNN', '15', 'TT*', '70', '', 'Tiền và tương đương tiền cuối kỳ (50+60+61)', '', 0, '', '', '0.00', '0.00', '0.00', '0.00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `quanlykt`
--

DROP TABLE IF EXISTS `quanlykt`;
CREATE TABLE `quanlykt` (
  `id` int(10) NOT NULL,
  `tentaptin` char(12) NOT NULL,
  `numid` char(12) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tenhang`
--

DROP TABLE IF EXISTS `tenhang`;
CREATE TABLE `tenhang` (
  `id` int(10) NOT NULL,
  `mahang` char(13) NOT NULL,
  `tenhang` char(100) NOT NULL,
  `donvi` char(8) NOT NULL,
  `sotk` char(6) NOT NULL,
  `userid` smallint(6) NOT NULL,
  `dongiakh` decimal(16,3) NOT NULL,
  `thuedt` decimal(5,2) NOT NULL,
  `dutru` decimal(16,3) NOT NULL,
  `newdonvi` char(8) NOT NULL,
  `newluong` char(20) NOT NULL,
  `dutrutt` decimal(16,3) NOT NULL,
  `dutrutd` decimal(16,3) NOT NULL,
  `table_` char(3) NOT NULL,
  `postion` char(3) NOT NULL,
  `code` char(15) NOT NULL,
  `descriptio` char(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tenmuc`
--

DROP TABLE IF EXISTS `tenmuc`;
CREATE TABLE `tenmuc` (
  `id` int(10) NOT NULL,
  `tkhoan` char(6) NOT NULL,
  `tenkhoan` char(50) NOT NULL,
  `kyhieu` char(3) NOT NULL,
  `ghichu` char(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `tenmuc`
--

INSERT INTO `tenmuc` (`id`, `tkhoan`, `tenkhoan`, `kyhieu`, `ghichu`) VALUES
(1497, '', '', '', '');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `username` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `datalist` varchar(255) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `admin` tinyint(1) DEFAULT 0,
  `role` int(11) NOT NULL DEFAULT 1,
  `gender` tinyint(1) DEFAULT NULL,
  `age` int(3) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `mobile` varchar(20) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `position` varchar(50) DEFAULT NULL,
  `status` tinyint(4) NOT NULL DEFAULT 0,
  `token` mediumtext DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `users`
--

INSERT INTO `users` (`id`, `username`, `name`, `email`, `datalist`, `address`, `password`, `admin`, `role`, `gender`, `age`, `dob`, `mobile`, `city`, `image`, `position`, `status`, `token`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Nghĩa ACN', 'Trần Văn Nghĩa', 'nghiatv@gmail.com', 'ketoan_xuanmai;ketoan_kingminh;ketoan_nhatnam', '118/63 Bạch Đằng ,p24,Bình Thạnh - HCM', '$2a$10$/E4TkCoFUEGj2lkr/UrmxuXafULxg.4/QKH2aesj7VlAX5Cz8U58a', 1, 2, 1, 50, '1961-12-15', '0903917963', 'Hồ Chí Minh', '/images/users/User_01.png', 'Software Development', 1, 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOlwvXC9sb2NhbGhvc3Q6ODAwMFwvYXBpXC9hdXRoXC9sb2dpbiIsImlhdCI6MTU4NTI4NDc0MSwiZXhwIjoxNTg1Mjg4MzQxLCJuYmYiOjE1ODUyODQ3NDEsImp0aSI6InBhSlZCazczcW4zSjloMUIiLCJzdWIiOjEsInBydiI6Ijg3ZTBhZjFlZjlmZDE1ODEyZmRlYzk3MTUzYTE0ZTBiMDQ3NTQ2YWEifQ.877jGS6mgv8lPZW2ktvvVmO3Y5jfSwnIP3HZLK322_8', 'r3H8CRJdjMQkNCpBwU16lkQILwdxnizaRx3wQLdLbbdmmvS0d20P1lNKCMVY', '2018-03-21 00:00:00', '2020-03-27 00:00:00'),
(5, 'Trọng Thủy', 'Trọng Thủy', '5nghiatv@gmail.com', 'ketoan_xuanmai;ketoan_kingminh;ketoan_nhatnam', '118/63 Bạch Đằng ,p24,Bình Thạnh - HCM', '$2a$10$/E4TkCoFUEGj2lkr/UrmxuXafULxg.4/QKH2aesj7VlAX5Cz8U58a', 0, 1, 1, 0, '1961-12-15', '0903917961', 'HCM', '/images/users/User_14.png', 'Kế toán Quỹ', 1, '', '', '2020-03-26 00:00:00', '2020-04-02 00:00:00'),
(6, 'Trần Vũ Anh', 'Trần Vũ Anh', 'quemuadotnat@gmail.com', 'ketoan_xuanmai;ketoan_kingminh;ketoan_nhatnam', '118/63 Bạch Đằng ,p24,Bình Thạnh - HCM', '$2a$10$/E4TkCoFUEGj2lkr/UrmxuXafULxg.4/QKH2aesj7VlAX5Cz8U58a', 0, 1, 1, 0, '1989-05-18', '0989199523', 'HCM', '/images/users/User_6.jpg', 'Kế toán viên', 1, '', '', '2020-03-26 00:00:00', '2020-04-02 00:00:00'),
(14, 'guest', 'Khách hàng', '123456@gmail.com', 'ketoan_xuanmai;ketoan_kingminh;ketoan_nhatnam', '118/63 Bạch Đằng ,p24,Bình Thạnh - HCM', '$2a$10$/E4TkCoFUEGj2lkr/UrmxuXafULxg.4/QKH2aesj7VlAX5Cz8U58a', 0, 1, 1, 0, '1961-12-14', '0989199523', 'HCM', '/images/users/logo-vuejs.png', 'Kế toán viên', 1, '', '', '2020-03-28 00:00:00', '2020-04-02 00:00:00'),
(17, 'nghiatv1', 'nghiatv1', 'github@gmail.com', '', '', '$2y$10$Y87OIC5JSXpVKq2bxMlsyeA1MuFpm.gJqnbg4GuhK8OQVmaKL8dQi', 0, 1, 0, 0, '0000-00-00', '', '', '', '', 0, 'pREa2AdI9v4UDxGzqkvzKALfh6Rn3m', '', '2020-04-02 00:00:00', '2020-04-02 00:00:00'),
(18, 'nghiatv', 'Trần Văn Nghĩa', 'twitter@gmail.com', '', '', '$2y$10$Oy8n/fV1OOqEAYYXlOqwBOip6HtHIZNgraW0tt0jIvxMsb22/PWwC', 0, 1, 0, 0, '0000-00-00', '', '', '/images/users/User_18.png', '', 0, 'lio2hpo2IQ7CEZLTbYfpRzqKbUu8tZ', '', '2020-04-08 00:00:00', '2020-04-10 00:00:00'),
(40, '5555@gmail.com', '5555@gmail.com', '5555@gmail.com', 'ketoan_xuanmai;ketoan_kingminh;', 'null', '$2a$10$nrcmSYG0S72QC8lA1jiuNOJBbdN1l.ckxI7Fk2t9Fg59OlJMxY7Wi', 0, 1, 0, 0, '0000-00-00', 'null', 'null', 'null', 'null', 0, 'null', 'null', '0000-00-00 00:00:00', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `user_lev`
--

DROP TABLE IF EXISTS `user_lev`;
CREATE TABLE `user_lev` (
  `id` int(10) NOT NULL,
  `group_id` char(3) NOT NULL,
  `descriptio` char(30) NOT NULL,
  `startup_ac` longtext NOT NULL,
  `kt1` tinyint(1) NOT NULL,
  `kt2` tinyint(1) NOT NULL,
  `kt3` tinyint(1) NOT NULL,
  `kt4` tinyint(1) NOT NULL,
  `kt5` tinyint(1) NOT NULL,
  `kt6` tinyint(1) NOT NULL,
  `kt7` tinyint(1) NOT NULL,
  `write_` tinyint(1) NOT NULL,
  `locked` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `user_lev`
--

INSERT INTO `user_lev` (`id`, `group_id`, `descriptio`, `startup_ac`, `kt1`, `kt2`, `kt3`, `kt4`, `kt5`, `kt6`, `kt7`, `write_`, `locked`) VALUES
(67, '  0', 'Quản trị hệ thống', '', 1, 1, 1, 1, 1, 1, 1, 1, ''),
(68, '  7', 'Kế toán tổng hợp', '', 1, 1, 1, 1, 1, 1, 1, 1, ''),
(69, '  1', 'Kế toán quỹ', '', 1, 0, 1, 0, 0, 1, 1, 1, ''),
(70, '  3', 'Kế toán công nợ', '', 1, 0, 1, 0, 0, 1, 1, 1, ''),
(71, '  2', 'Kế toán kho hàng', '', 0, 1, 1, 0, 0, 0, 1, 1, ''),
(72, '  8', 'APPLICATIONS DEVELOPER', '', 1, 1, 1, 1, 1, 1, 1, 1, ''),
(73, '  4', 'Kế toán Tài sản Cố định', '', 0, 0, 0, 1, 0, 0, 1, 1, ''),
(74, '  5', 'Kế toán giá thành SP', '', 0, 1, 0, 0, 1, 0, 1, 1, ''),
(75, '  6', 'Lao động tiền lương', '', 0, 0, 0, 0, 0, 1, 1, 1, ''),
(76, '  9', 'Giám đốc điều hành', '', 0, 0, 0, 0, 0, 0, 0, 0, ''),
(77, ' 10', 'Quan sát viên', '', 1, 1, 1, 1, 1, 1, 1, 0, '');

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `cdketoan`
--
ALTER TABLE `cdketoan`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `chitiet`
--
ALTER TABLE `chitiet`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ctid` (`ctid`),
  ADD KEY `matkno` (`matkno`),
  ADD KEY `matkco` (`matkco`),
  ADD KEY `tkno` (`tkno`,`matkno`) USING BTREE,
  ADD KEY `tkco` (`tkco`,`matkco`) USING BTREE;

--
-- Chỉ mục cho bảng `connect`
--
ALTER TABLE `connect`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `connects`
--
ALTER TABLE `connects`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `ctuktoan`
--
ALTER TABLE `ctuktoan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ctid` (`ctid`),
  ADD KEY `ngaysoct` (`ngay`,`soct`),
  ADD KEY `loaitien` (`loaitien`),
  ADD KEY `matkco` (`matkco`),
  ADD KEY `matkno` (`matkno`),
  ADD KEY `tkno` (`tkno`,`matkno`) USING BTREE,
  ADD KEY `tkco` (`tkco`,`matkco`) USING BTREE,
  ADD KEY `ngay` (`ngay`);

--
-- Chỉ mục cho bảng `ctuvattu`
--
ALTER TABLE `ctuvattu`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ctid` (`ctid`),
  ADD KEY `mahangkho` (`mahang`,`makho`),
  ADD KEY `makho` (`makho`),
  ADD KEY `mahang` (`mahang`);

--
-- Chỉ mục cho bảng `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`name`),
  ADD KEY `fullname` (`fullname`),
  ADD KEY `maso` (`maso`),
  ADD KEY `makhach` (`makhach`),
  ADD KEY `company` (`company`);

--
-- Chỉ mục cho bảng `dmkhohag`
--
ALTER TABLE `dmkhohag`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nammahangkho` (`nam`,`mahang`,`makho`),
  ADD KEY `mahang` (`mahang`),
  ADD KEY `makho` (`makho`),
  ADD KEY `nam` (`nam`);

--
-- Chỉ mục cho bảng `dmsodutk`
--
ALTER TABLE `dmsodutk`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `namsotktkhoan` (`nam`,`sotk`,`tkhoan`),
  ADD KEY `sotk` (`sotk`),
  ADD KEY `tkhoan` (`tkhoan`),
  ADD KEY `nam` (`nam`);

--
-- Chỉ mục cho bảng `dmtenkho`
--
ALTER TABLE `dmtenkho`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `makho` (`makho`);

--
-- Chỉ mục cho bảng `dmtiente`
--
ALTER TABLE `dmtiente`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `loaitien` (`loaitien`);

--
-- Chỉ mục cho bảng `dmtkhoan`
--
ALTER TABLE `dmtkhoan`
  ADD PRIMARY KEY (`sotk`),
  ADD UNIQUE KEY `id` (`id`),
  ADD KEY `tkhoan` (`tkhoan`),
  ADD KEY `sotktkhoan` (`sotk`,`tkhoan`);

--
-- Chỉ mục cho bảng `hoadon`
--
ALTER TABLE `hoadon`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ctid` (`ctid`),
  ADD KEY `mamauhd` (`mamauhd`);

--
-- Chỉ mục cho bảng `ketquakd`
--
ALTER TABLE `ketquakd`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `lctiente`
--
ALTER TABLE `lctiente`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `quanlykt`
--
ALTER TABLE `quanlykt`
  ADD PRIMARY KEY (`id`),
  ADD KEY `tentaptin` (`tentaptin`);

--
-- Chỉ mục cho bảng `tenhang`
--
ALTER TABLE `tenhang`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `mahang` (`mahang`);

--
-- Chỉ mục cho bảng `tenmuc`
--
ALTER TABLE `tenmuc`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `tkhoan` (`tkhoan`),
  ADD KEY `tenkhoan` (`tenkhoan`);

--
-- Chỉ mục cho bảng `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- Chỉ mục cho bảng `user_lev`
--
ALTER TABLE `user_lev`
  ADD PRIMARY KEY (`id`),
  ADD KEY `group_id` (`group_id`),
  ADD KEY `descriptio` (`descriptio`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `cdketoan`
--
ALTER TABLE `cdketoan`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=955;

--
-- AUTO_INCREMENT cho bảng `chitiet`
--
ALTER TABLE `chitiet`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `connect`
--
ALTER TABLE `connect`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT cho bảng `connects`
--
ALTER TABLE `connects`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `ctuktoan`
--
ALTER TABLE `ctuktoan`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `ctuvattu`
--
ALTER TABLE `ctuvattu`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `customer`
--
ALTER TABLE `customer`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `dmkhohag`
--
ALTER TABLE `dmkhohag`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `dmsodutk`
--
ALTER TABLE `dmsodutk`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `dmtenkho`
--
ALTER TABLE `dmtenkho`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `dmtiente`
--
ALTER TABLE `dmtiente`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `dmtkhoan`
--
ALTER TABLE `dmtkhoan`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `hoadon`
--
ALTER TABLE `hoadon`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `ketquakd`
--
ALTER TABLE `ketquakd`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6945;

--
-- AUTO_INCREMENT cho bảng `lctiente`
--
ALTER TABLE `lctiente`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2976;

--
-- AUTO_INCREMENT cho bảng `quanlykt`
--
ALTER TABLE `quanlykt`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tenhang`
--
ALTER TABLE `tenhang`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tenmuc`
--
ALTER TABLE `tenmuc`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1498;

--
-- AUTO_INCREMENT cho bảng `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT cho bảng `user_lev`
--
ALTER TABLE `user_lev`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=78;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `chitiet`
--
ALTER TABLE `chitiet`
  ADD CONSTRAINT `chitiet_ibfk_1` FOREIGN KEY (`tkno`) REFERENCES `dmtkhoan` (`sotk`) ON UPDATE CASCADE,
  ADD CONSTRAINT `chitiet_ibfk_2` FOREIGN KEY (`tkco`) REFERENCES `dmtkhoan` (`sotk`) ON UPDATE CASCADE,
  ADD CONSTRAINT `chitiet_ibfk_3` FOREIGN KEY (`ctid`) REFERENCES `ctuktoan` (`ctid`) ON UPDATE CASCADE,
  ADD CONSTRAINT `chitiet_ibfk_4` FOREIGN KEY (`matkno`) REFERENCES `tenmuc` (`tkhoan`) ON UPDATE CASCADE,
  ADD CONSTRAINT `chitiet_ibfk_5` FOREIGN KEY (`matkco`) REFERENCES `tenmuc` (`tkhoan`) ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `ctuktoan`
--
ALTER TABLE `ctuktoan`
  ADD CONSTRAINT `ctuktoan_ibfk_4` FOREIGN KEY (`loaitien`) REFERENCES `dmtiente` (`loaitien`) ON UPDATE CASCADE,
  ADD CONSTRAINT `ctuktoan_ibfk_5` FOREIGN KEY (`tkco`) REFERENCES `dmtkhoan` (`sotk`) ON UPDATE CASCADE,
  ADD CONSTRAINT `ctuktoan_ibfk_6` FOREIGN KEY (`tkno`) REFERENCES `dmtkhoan` (`sotk`) ON UPDATE CASCADE,
  ADD CONSTRAINT `ctuktoan_ibfk_7` FOREIGN KEY (`matkno`) REFERENCES `tenmuc` (`tkhoan`) ON UPDATE CASCADE,
  ADD CONSTRAINT `ctuktoan_ibfk_8` FOREIGN KEY (`matkco`) REFERENCES `tenmuc` (`tkhoan`) ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `ctuvattu`
--
ALTER TABLE `ctuvattu`
  ADD CONSTRAINT `ctuvattu_ibfk_2` FOREIGN KEY (`mahang`) REFERENCES `tenhang` (`mahang`) ON UPDATE CASCADE,
  ADD CONSTRAINT `ctuvattu_ibfk_3` FOREIGN KEY (`makho`) REFERENCES `dmtenkho` (`makho`) ON UPDATE CASCADE,
  ADD CONSTRAINT `ctuvattu_ibfk_4` FOREIGN KEY (`ctid`) REFERENCES `ctuktoan` (`ctid`) ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `dmkhohag`
--
ALTER TABLE `dmkhohag`
  ADD CONSTRAINT `dmkhohag_ibfk_1` FOREIGN KEY (`mahang`) REFERENCES `tenhang` (`mahang`) ON UPDATE CASCADE,
  ADD CONSTRAINT `dmkhohag_ibfk_2` FOREIGN KEY (`makho`) REFERENCES `dmtenkho` (`makho`) ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `dmsodutk`
--
ALTER TABLE `dmsodutk`
  ADD CONSTRAINT `dmsodutk_ibfk_1` FOREIGN KEY (`sotk`) REFERENCES `dmtkhoan` (`sotk`) ON UPDATE CASCADE,
  ADD CONSTRAINT `dmsodutk_ibfk_2` FOREIGN KEY (`tkhoan`) REFERENCES `tenmuc` (`tkhoan`) ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `hoadon`
--
ALTER TABLE `hoadon`
  ADD CONSTRAINT `hoadon_ibfk_1` FOREIGN KEY (`ctid`) REFERENCES `ctuktoan` (`ctid`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
