/*==============================================================*/
/* DBMS name:      HeThongQuanLyNhaKho                      */
/* Created on:     11/29/2023 4:56:50 PM                        */
/*==============================================================*/
use master;
drop database if exists HeThongQuanLyNhaKho
go
create database HeThongQuanLyNhaKho;
go
use HeThongQuanLyNhaKho;
go
/*==============================================================*/
/* Table: CAYGIONG                                              */
/*==============================================================*/
create table CAYGIONG 
(
   MACAYGIONG           varchar(10)                        ,
   TENCAYGIONG         Nvarchar(100)                 null,
   constraint PK_CAYGIONG primary key (MACAYGIONG)
);
/*==============================================================*/
/* Table: DOINHOM                                               */
/*==============================================================*/
create table DOINHOM 
(
   MADOINHOM           varchar(10)                    ,
   TENDOINHOM           Nvarchar   (100)                null,
   constraint PK_DOINHOM primary key (MADOINHOM)
);

/*==============================================================*/
/* Table: NHAKHO                                                */
/*==============================================================*/
create table NHAKHO 
(
   MANHAKHO             varchar(10)                        ,
   TENNHAKHO            Nvarchar(100)                 null,
   constraint PK_NHAKHO primary key (MANHAKHO)
);
/*==============================================================*/
/* Table: NHAKHO_CAYGIONG                                       */
/*==============================================================*/
CREATE TABLE NHAKHO_CAYGIONG 
(
   MANHAKHO             varchar(10)                        ,
   MACAYGIONG           varchar(10)                        ,
   CONSTRAINT PK_NHAKHO_CAYGIONG PRIMARY KEY (MANHAKHO, MACAYGIONG),
   CONSTRAINT FK_NHAKHO_CAYGIONG_NHAKHO FOREIGN KEY (MANHAKHO) REFERENCES NHAKHO(MANHAKHO)
);
/*==============================================================*/
/* Table: NHANVIEN                                              */
/*==============================================================*/
create table NHANVIEN 
(
   MANV                 varchar(10)                        ,
   MADOINHOM            varchar(10)                        ,
   THA_MANV             integer                        null,
   TENNV                nvarchar(100)                   null,
   NGAYSINH             date                           null,
   DIACHI               nvarchar(100)                   null,
   QUEQUAN              nvarchar(100)                   null,
   constraint PK_NHANVIEN primary key (MANV),
   CONSTRAINT FK_MADOINHOM_NV FOREIGN KEY (MADOINHOM) REFERENCES DOINHOM(MADOINHOM)
);
/*==============================================================*/
/* Table: NHANVIENCHAMSOC                                       */
/*==============================================================*/
create table NHANVIENCHAMSOC 
(
   MANV                 VARCHAR(10)                       ,
   KHUVUCLAMVIEC        nvarchar(100)                  ,
   constraint PK_NHANVIENCHAMSOC primary key (MANV),
);
/*==============================================================*/
/* Table: THANNHAN                                              */
/*==============================================================*/
create table THANNHAN 
(
   MANV                 varchar(10)                      ,
   HOTEN                char(10)                       ,
   NGAYSINH             date                           null,
   NGHENGHIEP           Nvarchar (100)                  null,
   SDT                  numeric(10)                    null,
   constraint PK_THANNHAN primary key (MANV , HOTEN),
   CONSTRAINT FK_NV_TN FOREIGN KEY (MANV) REFERENCES NHANVIEN(MANV)

);
go

--function tao mã số tự động cây nhà kho
CREATE FUNCTION generate_NhaKho()
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @MaxId INT;
    DECLARE @NewId VARCHAR(10);

    -- Lấy mã nhà kho lớn nhất
    SELECT @MaxId = MAX(CAST(SUBSTRING(MANHAKHO, 3, LEN(MANHAKHO) - 2) AS INT))
    FROM NHAKHO;

    -- Nếu không có bản ghi, gán giá trị mặc định là 0
    IF @MaxId IS NULL
        SET @MaxID = 0;

    -- Tạo mã nhà kho mới
    SET @NewId = 'NK' + RIGHT('0000' + CAST(@MaxID + 1 AS VARCHAR(4)), 4);

    RETURN @NewId;
END;
go

--function tao mã số tự động cây giống

CREATE FUNCTION Generate_MaCayGiong()
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @MaxID INT;
    DECLARE @NewID VARCHAR(10);

    -- Lấy mã cây giống lớn nhất
    SELECT @MaxID = MAX(CAST(SUBSTRING(MACAYGIONG, 3, LEN(MACAYGIONG) - 2) AS INT))
    FROM CAYGIONG;

    -- Nếu không có bản ghi, gán giá trị mặc định là 0
    IF @MaxID IS NULL
        SET @MaxID = 0;

    -- Tạo mã cây giống mới
    SET @NewID = 'CG' + RIGHT('0000' + CAST(@MaxID + 1 AS VARCHAR(4)), 4);

    RETURN @NewID;
END;
go
-- Tạo stored procedure de thêm 1 nhà kho mới
CREATE PROCEDURE Insert_NhaKho
    @TenNhaKho Nvarchar(100)
AS
BEGIN
    DECLARE @MaNhaKho VARCHAR(10);

    -- Gọi hàm để sinh mã nhà kho tự động
    SET @MaNhaKho = dbo.generate_NhaKho();

    -- Thêm bản ghi mới vào bảng NHAKHO
    INSERT INTO NHAKHO (MANHAKHO, TENNHAKHO)
    VALUES (@MaNhaKho, @TenNhaKho);
END;
go
-- Tạo stored procedure để thêm 1 cây giống mới
CREATE PROCEDURE Insert_CayGiong
    @TenCayGiong Nvarchar(100)
AS
BEGIN
    DECLARE @MaCayGiong VARCHAR(10);

    -- Gọi hàm để sinh mã cây giống tự động
    SET @MaCayGiong = dbo.Generate_MaCayGiong();

    -- Thêm bản ghi mới vào bảng CAYGIONG
    INSERT INTO CAYGIONG (MACAYGIONG, TENCAYGIONG)
    VALUES (@MaCayGiong, @TenCayGiong);
END;

--Test mã số tự động nhà kho 
EXEC Insert_NhaKho 'kho 1';
go
-- test mã số tự động cây giống
EXEC Insert_CayGiong 'Tên Cây Giống';
go
select * from CAYGIONG;
select * from NHAKHO;

go
-- Tạo trigger kiểm tra khóa ngoại của bảng nhân viên chăm sóc
-- kiểm tra khu vực làm việc không được để giá null
CREATE TRIGGER tr_CheckFK_NHANVIENCHAMSOC
ON NHANVIENCHAMSOC
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @CheckFK INT;

    -- Kiểm tra ràng buộc khoá ngoại
    SELECT @CheckFK = COUNT(*)
    FROM NHANVIENCHAMSOC nvc
    LEFT JOIN NHANVIEN nv ON nvc.MANV = nv.MANV
    WHERE nv.MANV IS NULL;

    -- Nếu có bản ghi không tồn tại trong NHANVIEN, rollback
    IF @CheckFK > 0
    BEGIN
        print (N'Khóa ngoại không hợp lệ')
        ROLLBACK;
        RETURN;
    END;

    -- Kiểm tra ràng buộc miền giá trị (ví dụ: kiểm tra KHUVUCLAMVIEC không được là NULL)
    IF EXISTS (SELECT 1 FROM INSERTED WHERE KHUVUCLAMVIEC IS NULL)
    BEGIN
        print (N'khu vực làm việc đang trống vui lòng điền vào khu vực làm việc')
        ROLLBACK;
        RETURN;
    END;
END;
go

--test trigger trên

-- Thêm dữ liệu vào bảng DOINHOM
INSERT INTO DOINHOM (MADOINHOM, TENDOINHOM)
VALUES ('DN001', 'Đội nhóm A'),
       ('DN002', 'Đội nhóm B'),
       ('DN003', 'Đội nhóm C');

-- Thêm du lieu vao bang nhân viên
INSERT INTO NHANVIEN (MANV, MADOINHOM, TENNV, NGAYSINH, DIACHI, QUEQUAN)
VALUES ('NV001', 'DN001', 'Nguyen Van A', '1990-01-01', 'Hanoi', 'Vietnam');

--kiểm tra ràng buộc khu vực làm việc không được null
INSERT INTO NHANVIENCHAMSOC (MANV, KHUVUCLAMVIEC) VALUES ('NV001', NULL);
