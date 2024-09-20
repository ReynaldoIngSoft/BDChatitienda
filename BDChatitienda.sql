create database chatiTienda;
use chatiTienda;


/*---------------------------------------------------TABLAS----------------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS tb_compra (
  idcompra int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  fechacompra date DEFAULT NULL,
  monto_total double DEFAULT NULL,
  idproveedor int,
  idusuario int
);

CREATE TABLE IF NOT EXISTS tb_productos (
  idproducto int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  descripcionproducto varchar(255) DEFAULT NULL,
  stock int DEFAULT NULL,
  precioventa double DEFAULT NULL,
  preciocompra double DEFAULT NULL,
  idtipoproducto int,
  idproveedor int
);

CREATE TABLE IF NOT EXISTS tb_proveedor (
  idproveedor int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nombreproveedor varchar(255) DEFAULT NULL,
  rucproveedor int DEFAULT NULL,
  direccionproveedor varchar(255) DEFAULT NULL,
  telefonoproveedor int DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS tb_tipo_producto (
  idtipoproducto int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  descripcionproducto varchar(255) DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS tb_ventas (
  idventas int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  fechaventa date DEFAULT NULL,
  montoventa double DEFAULT NULL,
  idcliente int,
  idusuario int
);

CREATE TABLE IF NOT EXISTS tb_usuario (
  idusuario int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nombreusuario varchar(255) DEFAULT NULL,
  dniusuario int DEFAULT NULL,
  idtipousuario int,
  estadousuario BOOLEAN DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS tb_detalle_ventas (
  iddetalleventas int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  idproducto int,
  idventas int,
  precioventa double DEFAULT NULL,
  cantidad int DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS tb_clientes (
  idcliente int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  dnicliente int DEFAULT NULL,
  nombrecliente varchar(255) DEFAULT NULL,
  telefonocliente int DEFAULT NULL,
  emailcliente varchar(255) DEFAULT NULL,
  direccioncliente varchar(255) DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS tb_tipo_usuario (
  idtipousuario int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  tipousuario varchar(255) DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS tb_detalle_compras (
  iddetallecompra int not null,
  idproducto int,
  idcompra int,
  preciocompra double DEFAULT NULL,
  precioventa double DEFAULT NULL,
  cantidad int DEFAULT NULL
);

alter table tb_detalle_compras
MODIFY iddetallecompra INT;
alter table tb_detalle_compras
drop column precioventa;

/***************************************LLAVES FORANEAS******************************************************/
 
 
  

ALTER TABLE tb_productos ADD CONSTRAINT fk_producto FOREIGN KEY (idtipoproducto) REFERENCES tb_tipo_producto(idtipoproducto);
ALTER TABLE tb_productos ADD CONSTRAINT fk_productotwo FOREIGN KEY (idproveedor) REFERENCES tb_proveedor(idproveedor);
ALTER TABLE tb_ventas ADD CONSTRAINT fk_ventas  FOREIGN KEY (idcliente) REFERENCES tb_clientes(idcliente);
ALTER TABLE tb_ventas ADD CONSTRAINT fk_ventastwo FOREIGN KEY (idusuario) REFERENCES tb_usuario(idusuario);
ALTER TABLE tb_detalle_ventas ADD CONSTRAINT fk_detalleventas FOREIGN KEY (idproducto) REFERENCES tb_productos(idproducto);
ALTER TABLE tb_detalle_ventas ADD CONSTRAINT fk_detalleventastwo FOREIGN KEY (idventas) REFERENCES tb_ventas(idventas);
ALTER TABLE tb_compra ADD CONSTRAINT fk_proveedor FOREIGN KEY (idproveedor) REFERENCES tb_proveedor(idproveedor);
ALTER TABLE tb_compra ADD CONSTRAINT fk_usuario FOREIGN KEY (idusuario) REFERENCES tb_usuario(idusuario);
ALTER TABLE tb_detalle_compras ADD CONSTRAINT fk_detallecompras FOREIGN KEY (idproducto) REFERENCES tb_productos(idproducto);
ALTER TABLE tb_detalle_compras ADD CONSTRAINT fk_detallecomprastwo FOREIGN KEY (idcompra) REFERENCES tb_compra(idcompra);
ALTER TABLE tb_usuario ADD CONSTRAINT fk_usuariotwo FOREIGN KEY (idtipousuario) REFERENCES tb_tipo_usuario(idtipousuario);

/***************************************************************************************************/
/*------------MODIFICACIONES---------------*/
/*se cambio el nombre de la columna iditipousuaio a idtipousuario */
ALTER TABLE tb_usuario
RENAME COLUMN iditipousuario TO idtipousuario;
/*-- se esta cambiando el tipo de dato del ruc debido a que es un numero muy grande*/
ALTER TABLE tb_proveedor
MODIFY rucproveedor varchar(11),
MODIFY telefonoproveedor varchar(9);

/*----  aumentar la columna genero a la tabla productos ----*/
ALTER TABLE tb_productos
ADD COLUMN genero ENUM('M','F') NOT NULL DEFAULT 'F';
/*-------------CAMBIAR EL  TIPO DE DATO DE ESTADO EN  TB_USUARIO------------*/
ALTER TABLE tb_usuario
MODIFY estadousuario boolean not null default false;

/**********************cambiar el tipo de monto_total a decimal  por recomendacion chatgpt++++++++++++++++*/
ALTER TABLE  tb_compra
MODIFY monto_total decimal(10,2) not null default 0.0;
/*-----------------------------------------------------------------*/

/*----------------------PROCEDURES DE PROVEEDORES-------------------------------------*/

DELIMITER $$
CREATE PROCEDURE validateRucUser(in  p_rucusuario char(11),in p_teleprovee char(9) ,out p_exists boolean)
begin
	declare user_count int;
    select count(*) into user_count
    from tb_proveedor
    where rucproveedor = p_rucusuario;
    select @user_count;
    if user_count > 0 then
		set p_exists = true;
    else
		set p_exists = false;
	end if;
end$$
DELIMITER ;
DELIMITER %%
CREATE PROCEDURE saveSupplier(in rucprove  char(11), in nomprove varchar(80), in direprove varchar(90), in teleprove char(9) )
	BEGIN
    declare userExist boolean;
    declare foneExist int;
    select  count(*) into foneExist
    from tb_proveedor  where telefonoprove = teleprove;
	call validateRucUser(rucprove,userExist);
    IF userExist then
		select 'este ruc ya esta registrado';
	else 
		if char_length(rucprove)<11 then
			select 'el ruc solo puede tener 11 digitos';	
        else
			if foneExist>0  then
				select 'el numero del telefono es unico para el registro de un proveedor';
			else																											
				insert into tb_proveedor(rucproveedor,nombreprove,direccionprove,telefonoprove) values
				(rucprove,nomprove,direprove,teleprove);
				select 'el proveedor ha sido registrado con exito';
			end if;
		end if;
    end if;
END%%
DELIMITER ;
/*---------------------------------------------------------------------------------------------*/
/***********************************************************************************************************/
/*+++++++++++++++++++++++++++++++++PROCEDIMIENTOS ALMACENADOS ++++++++++++++++++++++++++++++++++++++++++++++*/
	/*---------------------------PROCEDURE DE TIPO DE PRODUCTO ------------------------------------*/

DELIMITER %%
create procedure validarTipoProducto(in p_nombre varchar(20), out valor boolean)
	begin
	 declare p_name int;
     select count(*) into p_name
     from tb_tipo_producto as tp where tp.descripcionproducto = p_nombre;
     if p_name > 0 then
		set valor = true;
	else
		set valor = false;
	end if;
    end%%
DELIMITER 


delimiter %%
create procedure saveTipoProdu(in p_descripcionproducto varchar(80))
begin
	declare resultado boolean;
	call validarTipoProducto(p_descripcionproducto,resultado);
    if resultado then
		select 'este tipo de producto ya existe' as 'ERROR!!!';
	else
		insert into tb_tipo_producto(descripcionproducto) values(p_descripcionproducto);
        select 'tipo de producto guardado con exito' as 'GUARDADO';
	end if;
end %%
delimiter ;

CALL saveTipoProdu('bermuda');

/*********************************************************************************************************************/
DELIMITER %%
	create procedure saveCompra( p_idproveedor int, p_idusuario int)
    begin
		if p_idproveedor AND p_idusuario then
			insert into tb_compra (fechacompra, monto_total, idproveedor, idusuario)
            values(curdate(),0.0, p_idproveedor, p_idusuario);
            select idcompra from tb_compra;
        else 
			select 'ingrese los datos' as 'ERROR!!!';
        end if ;
    end%%
DELIMITER ;

CALL saveCompra(8,3);
/*++++++++++++++++++++++++++++++++PROCEDIMIENTOS DE GUARDADO DETALLE COMPRA +++++++++++++++++++++++++++++++*/

delimiter ++
create procedure saveDetalleCompra(p_iddetallecompra int, p_idproducto int, p_preciocompra double, p_cantidad int)	
	begin
		declare p_idcompra int;
        declare p_monto double;
        set p_monto = p_preciocompra * p_cantidad;
        set p_idcompra = LAST_INSERT_ID();
		if p_iddetallecompra and p_idproducto and p_preciocompra and p_cantidad then
				insert into tb_detalle_compras(iddetallecompra, idproducto, idcompra, preciocompra,cantidad)
				values(p_iddetallecompra, p_idproducto, p_idcompra, p_preciocompra, p_cantidad);
                update tb_compra
                set monto_total =monto_total + p_monto
                where idcompra = p_idcompra;
                update tb_productos
                set stock = stock + p_cantidad
                where idproducto = p_idproducto;
			else
				select 'ingrese los datos' as 'ERROR!!!';
		end if ;
	end++ 
delimiter ;
/*********************************Consulta de compras********************************************************/

delimiter %%
create procedure consultaFactura(p_idcompra int )
begin
	select co.idcompra, co.fechacompra, co.monto_total, prove.nombreproveedor from tb_compra as co 
    inner join tb_proveedor as prove  on co.idproveedor = prove.idproveedor
    where co.idcompra = p_idcompra;
    
    select  produ.descripcionproducto, dc.cantidad, dc.preciocompra, (dc.cantidad * dc.preciocompra) as total  from tb_detalle_compras as dc
    inner join tb_productos as produ on dc.idproducto = produ.idproducto
    where dc.idcompra = p_idcompra ;
end%% 
delimiter ;

call consultaFactura(21);
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/












