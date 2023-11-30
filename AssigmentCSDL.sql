create database ctyphm
use ctyphm

create table Nhanvien (
	msnv varchar(10) primary key,
	hoten nvarchar(30),
	ngaysinh date,
	gioitinh varchar(3),
	quequan nvarchar(50),
	manhom varchar(10) foreign key references Nhom(manhom)
)

create table NVLT (
	msnv varchar(10) foreign key references Nhanvien(msnv),
	nnlt varchar(40)
	primary key(msnv)
)

create table NVKT (
	msnv varchar(10) foreign key references Nhanvien(msnv),
	loaikiemthu nvarchar(50),
	primary key(msnv)
)

create table Thannhan (
	msnv varchar(10) foreign key references Nhanvien(msnv),
	hoten nvarchar(50),
	ngaysinh date,
	nghenghiep nvarchar(30),
	sdt varchar(10),
	primary key(msnv, hoten)
)

drop table Thannhan

create table Nhom (
	manhom varchar(10) primary key,
	tennhom nvarchar(30),
	msnv varchar(10)
)

alter table Nhom add constraint fk_msnv foreign key(msnv) references Nhanvien(msnv)

insert into Nhom values (
	'DD', N'Đỗ Đăng', null
)

insert into Nhom values (
	'VB', N'Văn Biên', null
)

select * from Nhom

create table Duan (
	mada varchar(10) primary key,
	tenduan nvarchar(30),
	manhom varchar(10) foreign key references Nhom(manhom)
)

create table NhanvienDuan (
	msnv varchar(10),
	mada varchar(10),
	ngaythamgia date,
	ngayhoanthanh date,
	nhiemvu nvarchar(50),
	nhanxet nvarchar(50),
	primary key(msnv, mada),
	foreign key(mada) references Duan(mada),
	foreign key(msnv) references Nhanvien(msnv)
)

create function genID_DA ()
returns varchar(10)
as 
Begin 
	DECLARE @msda varchar(10), @type varchar(10)
    set @msda = (select top 1 mada from Duan order by mada desc)
    if(@msda is null)
    	return 'Du an' + '001'
    DECLARE @stt int 
    set @stt = cast(right(@msda,3) as int) + 1 
    if @stt < 10 
    	set @msda = 'Duan' + '00' + cast (@stt as varchar(10)) 
    else if @stt < 100 
    	set @msda = 'Duan' + '0' + cast (@stt as varchar(10)) 
    else 
    	set @msda = 'Duan' + cast (@stt as varchar(10)) 
   return @msda
end 


drop function genID_DA


create function genID (@manhom varchar(10))
returns varchar(10)
as 
Begin 
	DECLARE @msnv varchar(10), @type varchar(10)
    set @msnv = (select top 1 msnv from Nhanvien where 
                 manhom = @manhom order by msnv desc)
    if(@msnv is null)
    	return @manhom + '001'
    DECLARE @stt int 
    set @stt = cast(right(@msnv,3) as int) + 1 
    if @stt < 10 
    	set @msnv = @manhom + '00' + cast (@stt as varchar(10)) 
    else if @stt < 100 
    	set @msnv = @manhom + '0' + cast (@stt as varchar(10)) 
    else 
    	set @msnv = @manhom + cast (@stt as varchar(10)) 
   return @msnv
end 

drop function genID



create proc add_nv @ht nvarchar(30),  @ns date, @gt varchar(3), @qq nvarchar(50), @manhom varchar(10)
as  
	insert into Nhanvien values (dbo.genID(@manhom), @ht, @ns, @gt, @qq, @manhom)



create proc add_da @tenda nvarchar(30), @manhom varchar(10)
as  
	insert into Duan values (dbo.genID_DA(), @tenda, @manhom)

exec add_nv N'Đạo Thanh Hưng', '2003/06/14', 'Nam', N'Ninh Thuận', 'DD'
exec add_nv N'Nguyễn Văn Thịnh', '2003/07/12', 'Nam', N'Quảng Ngãi', 'DD'
exec add_nv N'Hồ Đặng Tuấn Vũ', '2003/04/24', 'Nam', N'Bình Định', 'VB'
exec add_nv N'Đỗ Minh Đăng', '2003/11/25', 'Nam', N'Lâm Đồng', 'VB'
exec add_nv N'Đỗ Minh Đăng', '2003/11/25', 'Nam', N'Lâm Đồng', 'VB'
exec add_da N'Web API', 'DD'
exec add_da N'App Flutter', 'VB'

select * from Duan
update Nhom set msnv ='DD001' where manhom = 'DD'
select * from Nhom
select * from Nhanvien
delete from Nhom

create trigger traddNVKT on NVKT 
for insert
as 
	declare @msnv varchar(10)
	declare @type nvarchar(50)

    select @msnv = msnv from inserted
	select @type = loaikiemthu from inserted

    if (@msnv not in (select msnv from Nhanvien))
    begin 
    	print ('Khoa ngoai khong hop le')
        rollback tran
    end 
	if(@type not like N'Tu dong' and @type not like N'Thu cong')
	begin
		print('Loai kiem thu phai la tu dong hoac thu cong')
		rollback tran
	end

create trigger traddNVLT on NVLT 
for insert
as 

	declare @msnv varchar(10)
	declare @nnlt nvarchar(50)

    select @msnv = msnv from inserted
	select @nnlt = nnlt from inserted

    if (@msnv not in (select msnv from Nhanvien))
    begin 
    	print ('Khoa ngoai khong hop le')
        rollback tran
    end 
	if(@nnlt not in ('C#', 'Java', 'Python', 'Javascript'))
	begin
		print('NNLT nay khong duoc su dung o cong ty')
		rollback tran
	end


drop trigger traddNVKT
INSERT into Lop VALUES('TH', N'Tin hoc')
insert into Thannhan values ('DD001', N'Vũ vicotr', '2005/07/12', N'Lập trình', '034324')
select * from Thannhan

insert into NVKT values ('DD001', N'Tu dong')
insert into NVLT values ('DD002', 'Java')
select * from NVKT
select * from NVLT
select sv.*, NVKT.loaikiemthu from Nhanvien sv inner join NVKT on sv.msnv = NVKT.msnv