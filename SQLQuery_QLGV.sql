USE master
IF EXISTS  (SELECT * FROM SYS.databases WHERE NAME = 'QLGV')
BEGIN
	ALTER DATABASE QLGV SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE QLGV;
END
GO

CREATE DATABASE QLGV
GO

USE QLGV
GO

CREATE TABLE KHOA 
(
	MAKHOA VARCHAR(4) PRIMARY KEY,
	TENKHOA VARCHAR(40),
	NGTLAP SMALLDATETIME,
	TRGKHOA CHAR(4),
)
GO

CREATE TABLE MONHOC
(
	MAMH VARCHAR(10) PRIMARY KEY,
	TENMH VARCHAR(40),
	TCLT TINYINT,
	TCTH TINYINT,
	MAKHOA VARCHAR(4) FOREIGN KEY REFERENCES KHOA(MAKHOA),
)
GO

CREATE TABLE DIEUKIEN
(
	MAMH VARCHAR(10) FOREIGN KEY REFERENCES MONHOC(MAMH),
	MAMH_TRUOC VARCHAR(10),
	PRIMARY KEY (MAMH, MAMH_TRUOC)
)
GO

CREATE TABLE GIAOVIEN
(
	MAGV CHAR(4) PRIMARY KEY,
	HOTEN VARCHAR(40),
	HOCVI VARCHAR(10),
	HOCHAM VARCHAR(10),
	GIOITINH VARCHAR(3),
	NGSINH SMALLDATETIME,
	NGVL SMALLDATETIME,
	HESO NUMERIC(4,2),
	MUCLUONG MONEY,
	MAKHOA VARCHAR(4) FOREIGN KEY REFERENCES KHOA(MAKHOA)
)
GO

CREATE TABLE LOP
(
	MALOP CHAR(3) PRIMARY KEY,
	TEMLOP VARCHAR(40),
	TRGLOP CHAR(5),
	SISO TINYINT,
	MAGVCN CHAR(4) FOREIGN KEY REFERENCES GIAOVIEN(MAGV),
)
GO

CREATE TABLE HOCVIEN
(
	MAHV CHAR(5) PRIMARY KEY,
	HO VARCHAR(40),
	TEN VARCHAR(10),
	NGSINH SMALLDATETIME,
	GIOITINH VARCHAR(3),
	NOISINH VARCHAR(40),
	MALOP CHAR(3) FOREIGN KEY REFERENCES LOP(MALOP)
)
GO

CREATE TABLE GIANGDAY
(
	MALOP CHAR(3) FOREIGN KEY REFERENCES LOP(MALOP),
	MAMH VARCHAR(10) FOREIGN KEY REFERENCES MONHOC(MAMH),
	MAGV CHAR(4) FOREIGN KEY  REFERENCES GIAOVIEN(MAGV),
	HOCKY TINYINT,
	NAM SMALLINT,
	TUNGAY SMALLDATETIME,
	DEMNGAY SMALLDATETIME,
	PRIMARY KEY (MALOP, MAMH),
)
GO

CREATE TABLE KETQUATHI
(
	MAHV CHAR(5) FOREIGN KEY REFERENCES HOCVIEN(MAHV),
	MAMH VARCHAR(10) FOREIGN KEY REFERENCES MONHOC(MAMH),
	LANTHI TINYINT,
	NGTHI SMALLDATETIME,
	DIEM NUMERIC(4,2),
	KQUA VARCHAR(10),
	PRIMARY KEY(MAHV, MAMH, LANTHI),
)
GO

ALTER TABLE KHOA ADD CONSTRAINT FK_KHOA_TRGKHOA FOREIGN KEY (TRGKHOA) REFERENCES GIAOVIEN(MAGV)

ALTER TABLE HOCVIEN ADD GHICHU VARCHAR(60)
GO

ALTER TABLE HOCVIEN ADD DIEMTB NUMERIC(4,2)
GO

ALTER TABLE HOCVIEN ADD XEPLOAI VARCHAR(10)
GO

--2.
CREATE FUNCTION check_valid_MALOP (@MAHV VARCHAR(5))
RETURNs TINYINT
AS 
BEGIN
	IF LEFT(@MAHV, 3) IN (SELECT MALOP FROM LOP)
		RETURN 1
	RETURN 0
END
GO

CREATE FUNCTION check_valid_STT (@MAHV VARCHAR(5), @MALOP_HOCVIEN VARCHAR(3))
RETURNs TINYINT
AS
BEGIN
    IF RIGHT(@MAHV, 2) BETWEEN 1 AND (SELECT SISO FROM LOP WHERE MALOP = @MALOP_HOCVIEN)
		RETURN 1
	RETURN 0
END
GO

ALTER TABLE HOCVIEN ADD CONSTRAINT CK_MAHV CHECK(
	LEN(MAHV) = 5 AND 
	dbo.check_valid_MALOP(MAHV) = 1 AND 
	dbo.check_valid_STT(MAHV, MALOP) = 1
)
GO

--3.
ALTER TABLE HOCVIEN ADD CONSTRAINT CK_GIOITINH CHECK(GIOITINH IN ('NAM','NU'))
GO
--4.
ALTER TABLE KETQUATHI ADD CONSTRAINT CK_DIEM CHECK
(
	DIEM BETWEEN 0 AND 10 AND
	LEN(SUBSTRING(CAST(DIEM AS VARCHAR), CHARINDEX('.', DIEM) +1,1000))>=2
)
GO

--5.
ALTER TABLE KETQUATHI ADD CONSTRAINT CK_KUA CHECK(KQUA = IIF( DIEM BETWEEN 5 AND 10, 'DAT', 'KHONG DAT'))
GO

--6.
ALTER TABLE KETQUATHI ADD CONSTRAINT CK_SOLANTHI CHECK(LANTHI <= 3)
GO

--7.
ALTER TABLE GIANGDAY ADD CONSTRAINT CK_HOCKY CHECK(HOCKY BETWEEN 1 AND 3)
GO

--8.
ALTER TABLE GIAOVIEN ADD CONSTRAINT CK_HOCVI CHECK(HOCVI IN ('CN', 'KS', 'Ths', 'TS', 'PTS'))
GO