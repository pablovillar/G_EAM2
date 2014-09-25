********************************
*** UNION SERIE 2005 - 2012 ****
* ENCUESTA ANUAL MANUFACTURERA *
********************************

** Cargar directorios 2005-2009
* Pegar informaci�n por Empresa y establecimiento sin colapsar
clear 
set more off, perm

forval i=5(1)9 {
clear
cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\200`i'"
use control0`i', clear 
merge 1:1 nordemp nordest using nuevas0`i'
rename _merge _m1
merge 1:1 nordemp nordest using cap26i0`i'
rename _merge _m2
merge 1:1 nordemp nordest using cap35i0`i'
rename _merge _m3
merge 1:1 nordemp nordest using cap4i0`i'
rename _merge _m4
merge 1:1 nordemp nordest using cap7i0`i'
rename _merge _m5
order _m* , last
keep if _m1==3 // dejar empresas con identificaci�n geogr�fica y comercial
drop _m*
g periodo=200`i' // se crea el indicador de a�o para el panel
order periodo
cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\panel"
save emp_est_200`i', replace
}


** Cargar directorios 2010-2012
* Pegar informaci�n por Empresa y establecimiento sin colapsar
forval i=10(1)12 {
clear
cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\20`i'"
use control`i', clear 
merge 1:1 nordemp nordest using nuevas`i'
rename _merge _m1
merge 1:1 nordemp nordest using cap26i`i'
rename _merge _m2
merge 1:1 nordemp nordest using cap35i`i'
rename _merge _m3
merge 1:1 nordemp nordest using cap4i`i'
rename _merge _m4
merge 1:1 nordemp nordest using cap7i`i'
rename _merge _m5
order _m* , last
keep if _m1==3 // dejar empresas con identificaci�n geogr�fica y comercial
drop _m*
g periodo=20`i' // se crea el indicador de a�o para el panel
order periodo
cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\panel"
save emp_est_20`i', replace
}

/*
quedan por incluir
dire // este solo est� desde 2008 y es por empresa, antes estan combinados dir y dire por establecimiento 
dir // Esta el a�o de creacion del establecimiento
materia // no se incluye
producto // Se tiene que incluir porque est� contenida la informaci�n de producci�n y VENTAS
*/


***********************************
** Crear la base de a�o de creacion
clear
cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\panel"
input periodo nordest anope
1 1 1
end 
drop in 1
save ano_creacion, replace

forval i=5(1)7 {
clear
cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\200`i'"
use dir0`i', clear
replace anope=. if anope==0
keep nordest anope
rename anoper anope  
g periodo=200`i' // se crea el indicador de a�o para el panel
order periodo
cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\panel"
append using ano_creacion
save ano_creacion, replace
}

forval i=8(1)9 {
clear
cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\200`i'"
use dir0`i', clear
replace anope=. if anope==0
keep nordest anope
g periodo=200`i' // se crea el indicador de a�o para el panel
order periodo
cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\panel"
append using ano_creacion
save ano_creacion, replace
}

forval i=10(1)12 {
clear
cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\20`i'"
use dir`i', clear
replace anope=. if anope==0 
g periodo=20`i' // se crea el indicador de a�o para el panel
order periodo
cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\panel"
append using ano_creacion
save ano_creacion, replace
}


*********************************************
** Crear la base de ventas y producci�n anual
clear
cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\panel"
input periodo nordemp valvfab valorven porcvt
1 1 1 1 1
end 
drop in 1
save produccion_y_ventas, replace


forval i=5(1)9 {
clear
cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\200`i'"
use producto0`i', clear
keep nordemp valvfab valorven porcvt
if `i'<=7 {
	g porc_ventas_extr=porcvt/100
	replace porcvt=round(valorven*porc_ventas_extr,1)
	drop porc_ventas_extr
	g periodo=200`i' // se crea el indicador de a�o para el panel
	collapse (sum) valvfab valorven porcvt , by(nordemp periodo)  // los a�os 2005-2007 tienen porcentaje de ventas al extranjero y no valores  
	order periodo nordemp valvfab valorven porcvt
	cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\panel"
	append using produccion_y_ventas
	save produccion_y_ventas, replace
	}
else {
	g periodo=200`i' // se crea el indicador de a�o para el panel
	collapse (sum) valvfab valorven porcvt , by(nordemp periodo)  // los a�os 2005-2007 tienen porcentaje de ventas al extranjero y no valores  
	order periodo nordemp valvfab valorven porcvt
	cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\panel"
	append using produccion_y_ventas
	save produccion_y_ventas, replace
	}
}


forval i=10(1)12 {
clear
cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\20`i'"
use producto`i', clear
keep nordemp valvfab valorven porcvt
g periodo=20`i' // se crea el indicador de a�o para el panel
collapse (sum) valvfab valorven porcvt , by(nordemp periodo)  // los a�os 2005-2007 tienen porcentaje de ventas al extranjero y no valores  
order periodo nordemp valvfab valorven porcvt
cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\panel"
append using produccion_y_ventas
save produccion_y_ventas, replace
}


************************************
*** Construcci�n del panel final ***
************************************

clear
cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\panel"
forval i=2005(1)2012 {
use emp_est_`i', clear
tostring _all, replace force
save emp_est_`i', replace
}


use emp_est_2005
forval i=2006(1)2012 {
append using emp_est_`i' , force
}
destring _all, replace
compress
save panel, replace

** Dejar variables de inter�s

use panel, clear
merge 1:1 periodo nordest using ano_creacion  // unir a�o de creaci�n de cada establecimiento
keep if _m==3
drop _m

order _all , alpha
sort nordemp nordest periodo

replace anope=anope[_n-1] if anope==. & anope[_n-1]!=. & nordest==nordest[_n-1] 
replace anope=anope[_n+1] if anope==. & anope[_n+1]!=. & nordest==nordest[_n+1] 
drop if anope==.

replace dpto=dptoest if dpto==. // hay departamentos en blanco porque tienen nombre distintos en los a�os, para solucionar se reemplazan los missing
replace dpto=dpto[_n-1] if dpto==. & dpto[_n-1]!=. & nordest==nordest[_n-1] 
replace dpto=dpto[_n+1] if dpto==. & dpto[_n+1]!=. & nordest==nordest[_n+1] 

g numero_est=1 // Crear la variable n�mero de establecimientos para cada empresa

sort periodo nordemp anope nordest
collapse (firstnm) anope ciiu orgju dpto  /// variables de localizaci�n 
(sum) c4r*n                        /// empleados profesionales nacionales
(sum) c4r*e                        /// empleados profesionales extranjeros
(sum) c4r*c1 c4*om c4r*c2 c4*oh    /// obreros y operarios
(sum) c4r*c3 c4*dm c4r*c4 c4*dh    /// directivos y empleaods de admon y ventas
(sum) c4r*t c4*tm c4*th            /// Total empleados empresa
(sum) c3r1pt c3r1c1 c3r1c2 c3r1c3      /// Salario integral permanentes EN MILES DE PESOS
(sum) c3r2pt c3r2c1 c3r2c2 c3r2c3      /// Salario permanentes EN MILES DE PESOS
(sum) c3r3pt c3r3c1 c3r3c2 c3r3c3      /// Prestaciones sociales permanentes EN MILES DE PESOS
(sum) c3r4pt c3r4c1 c3r4c2 c3r4c3      /// Sueldo y prestaciones temporales EN MILES DE PESOS
(sum) c3r8pt c3r8c1 c3r8c2 c3r8c3      /// Valor temporales indirectos EN MILES DE PESOS
(sum) c3r10pt c3r10c1 c3r10c2 c3r10c3  /// TOTAL salarios, prestaciones, otros EN MILES DE PESOS
(sum) c3r35c1 c3r35c2 c3r35c3      /// Costos y gastos causados totales (no dice que sea en miles de pesos, REVISAR)
(sum) c7r10c1    /// Valor en libros inicio de a�o EN MILES DE PESOS
(sum) c7r10c6    /// Valor en libros Final de a�o EN MILES DE PESOS
(sum) c7r10c7    /// Depreciaci�n causada transcurso del a�o EN MILES DE PESOS
(sum) c6r5c1           /// Inventarios inicio de a�o EN MILES DE PESOS 
(sum) c6r5c3           /// Inventarios final de a�o EN MILES DE PESOS 
(sum) activfi     /// activos fijos
(sum) consin      /// otros gastos
(sum) consin2     /// consumo intermedio
(sum) consmate    /// consumo de materias
(sum) deprecia    /// depreciaci�n
(sum) eelec       /// energia electrica en kw
(sum) invebrta    /// Inversi�n bruta
(sum) inveneta    /// Inversi�n neta
(sum) persocu     /// personal permanente
(sum) persoesc    /// personal permanente + propietarios
(sum) pertem3     /// personal temporal directo
(sum) pperytem    /// personal permanente + temporal directo
(sum) pertotal    /// personal permanente + propietarios +personal temporal directo + temporal empresas 
(sum) prespyte    /// prestaciones sociales de permantente y temporal directo
(sum) pressper    /// prestaciones de permantente
(sum) prodbind    /// producci�n industrial
(sum) prodbr2     /// producci�n bruta
(sum) salarper    /// salario de permanentes 
(sum) salpeyte    /// sueldos y salarios personal permanente y temporal
(sum) valagri     /// valor agregado
(sum) numero_est     /// N�mero de establecimientos por empresa
, by(nordemp periodo)


merge 1:1 nordemp periodo using produccion_y_ventas // pegar informaci�n de produccion y ventas
keep if _m==3
drop _m

bysort nordemp: egen ano_creacion=mode(anope) , minmode // corregir inconsistencias a�o de creacion diferentes entre a�os
replace anope=ano_creacion
drop ano_creacion

save panel_clean, replace

* Colocar labels
use panel_clean, clear

sort nordemp periodo
label data "Panel EAM 2005-2012"

label var nordemp "No orden empresa"
label var periodo "A�o del panel"
label var anope "a�o creaci�n empresa"
label var ciiu "C�digo CIIU"
label var orgju "Tipo de organizaci�n"
label var dpto "Departamento"
label var c4r1c10n "TOTAL PROFESIONALES, T�CNICOS Y TECN�LOGOS, NACIONALES, hombres"
label var c4r1c1n "Propietarios socios y familiares PROFESIONALES, T�CNICOS Y TECNOLOGOS, mujeres y nacionales"
label var c4r1c2n "Propietarios socios y familiares, PROFESIONALES, T�CNICOS Y TECNOLOGOS, hombres y nacionales"
label var c4r1c3n "Personal permanente, PROFESIONALES, T�CNICOS Y TECNOLOGOS, NACIONAL, hombres"
label var c4r1c4n "Personal permanente, PROFESIONALES, T�CNICOS Y TECNOLOGOS, NACIONAL mujeres"
label var c4r1c5n "Temporal contratado directamente, PROFESIONALES, T�CNICOS Y TECNOLOGOS, NACIONALES, mujeres"
label var c4r1c6n "Temporal contratado directamente, PROFESIONALES, T�CNICOS Y TECNOLOGOS, NACIONALES, hombres"
label var c4r1c7n "Temporal contratado a trav�s de empresas, PROFESIONALES, T�CNICOS Y TECNOLOGOS, NACIONALES, mujeres"
label var c4r1c8n "Temporal contratado a trav�s de empresas PROFESIONALES T�CNICOS Y TECNOLOGOS, NACIONALES, hombres"
label var c4r1c9n "total PROFESIONALES, T�CNICOS Y TECN�LOGOS, NACIONALES, mujeres"
label var c4r6hn "Aprendices y pasantes profesionales nacionales hombres"
label var c4r6mn "Aprendices y pasantes  profesionales nacionales mujeres"
label var c4r2c10e "TOTAL PROFESIONALES, T�CNICOS Y TECN�LOGOS, EXTRANJEROS, hombres"
label var c4r2c1e "Propietarios socios y familiares PROFESIONALES, T�CNICOS Y TECNOLOGOS, mujeres y extranjeros"
label var c4r2c2e "Propietarios socios y familiares PROFESIONALES, T�CNICOS Y TECNOLOGOS, hombres y extranjeros"
label var c4r2c3e "Personal permanente, PROFESIONALES, T�CNICOS Y TECNOLOGOS, EXTRANJERO, hombres"
label var c4r2c4e "Personal permanente, PROFESIONALES, T�CNICOS Y TECNOLOGOS, EXTRANJERO mujeres"
label var c4r2c5e "Temporal contratado directamente, PROFESIONALES, T�CNICOS Y TECNOLOGOS, EXTRANJEROS, hombres"
label var c4r2c6e "Temporal contratado directamente, PROFESIONALES, T�CNICOS Y TECNOLOGOS, EXTRANJEROS, mujeres"
label var c4r2c7e "Temporal contratado a trav�s de empresas, PROFESIONALES, T�CNICOS Y TECNOLOGOS, EXTRANJEROS, mujeres"
label var c4r2c8e "Temporal contratado a trav�s de empresas especializadas extranjeros hombres"
label var c4r2c9e "TOTAL PROFESIONALES, T�CNICOS Y TECN�LOGOS, EXTRANJEROS, mujeres"
label var c4r6he "Aprendices y pasantes  profesionales extranjeros hombres"
label var c4r6me "Aprendices y pasantes  profesionales extranjeros mujeres"
label var c4r1c1 "Propietarios socios y familiares, OBREROS Y OPERARIOS, mujeres"
label var c4r2c1 "Personal permanente, OBREROS Y OPERARIOS, hombres"
label var c4r3c1 "Temporal contratado directamente, OBREROS Y OPERARIOS, mujeres"
label var c4r4c1 "Temporal contratado a trav�s de empresas OBREROS Y OPERARIOS, mujeres"
label var c4r5c1 "TOTAL de OBREROS Y OPERARIOS, mujeres"
label var c4r6om "Aprendices y pasantes obreros mujeres"
label var c4r1c2 "Propietarios socios y familiares, OBREROS Y OPERARIOS, hombres"
label var c4r2c2 "Personal permanente, OBREROS Y OPERARIOS, mujeres"
label var c4r3c2 "Temporal contratado directamente, OBREROS Y OPERARIOS, hombres"
label var c4r4c2 "Temporal contratado a trav�s de empresas OBREROS Y OPERARIOS, hombres"
label var c4r5c2 "TOTAL de OBREROS Y OPERARIOS, hombres"
label var c4r6oh "Aprendices y pasantes obreros hombres"
label var c4r1c3 "Propietarios socios y familiares, DIRECTIVOS, mujeres"
label var c4r2c3 "Personal permanente, DIRECTIVOS, mujeres"
label var c4r3c3 "Temporal contratado directamente, DIRECTIVOS, mujeres"
label var c4r4c3 "Temporal contratado a trav�s de empresas DIRECTIVOS, mujeres"
label var c4r5c3 "TOTAL DIRECTIVOS, mujeres"
label var c4r6dm "Aprendices y pasantes directivos, administraci�n y ventas mujeres"
label var c4r1c4 "Propietarios socios y familiares, DIRECTIVOS, hombres"
label var c4r2c4 "Personal permanente, DIRECTIVOS, hombres"
label var c4r3c4 "Temporal contratado directamente, DIRECTIVOS, hombres"
label var c4r4c4 "Temporal contratado a trav�s de empresas DIRECTIVOS, hombres"
label var c4r5c4 "TOTAL DIRECTIVOS, hombres"
label var c4r6dh "Aprendices y pasantes directivos, administraci�n y ventas hombres"
label var c4r4c10t "TOTAL PERSONAL OCUPADO, hombres"
label var c4r4c1t "Total Propietarios socios y familiares, TOTAL PERSONAL OCUPADO, mujeres"
label var c4r4c2t "Total Propietarios socios y familiares, TOTAL PERSONAL OCUPADO, hombres"
label var c4r4c3t "Total Personal permanente, TOTAL PERSONAL OCUPADO, mujeres"
label var c4r4c4t "Total Personal permanente, TOTAL PERSONAL OCUPADO, hombres"
label var c4r4c5t "Total temporal contratado directamente, PERSONAL OCUPADO, mujeres"
label var c4r4c6t "Total temporal contratado directamente, PERSONAL OCUPADO, hombres"
label var c4r4c7t "Total temporal contratado a trav�s de empresas PERSONAL OCUPADO, mujeres"
label var c4r4c8t "Total temporal contratado a trav�s de empresas PERSONAL OCUPADO, hombres"
label var c4r4c9t "TOTALPERSONAL OCUPADO, mujeres"
label var c4r6tm "TOTAL Aprendices y pasantes mujeres"
label var c4r6th "TOTAL Aprendices y pasantes hombres"
label var c3r1pt "Salario Integral para el personal permanente Personal vinculado directamente a la producci�n Profesionales"
label var c3r1c1 "Materias primas, materiales y empaques consumidos"
label var c3r1c2 "Salario Integral para el personal permanente directivos, administraci�n y ventas"
label var c3r1c3 "Total costos producci�n Materias primas consumidas"
label var c3r2pt "sueldos y salarios personal permanente Personal vinculado directamente a la producci�n Profesionales"
label var c3r2c1 "sueldos y salarios personal permanente Personal vinculado directamente a la producci�n obreros"
label var c3r2c2 "Gastos Admon � Costo de vta prod no fabricados"
label var c3r2c3 "Total Costo de vta prod no fabricados"
label var c3r3pt "prestaciones sociales personal permanente Personal vinculado directamente a la producci�n"
label var c3r3c1 "Costo de vta. de materias primas, materiales y empaques vendidos sin transformar, PRODUCCION."
label var c3r3c2 "Costo de vta. de materias primas, materiales y empaques vendidos sin transformar, ADMINISTRACI�N Y VENTAS."
label var c3r3c3 "Total Costo de vta. de materias primas, materiales y empaques vendidos sin transformar."
label var c3r4pt "Sueldos, salarios y prestaciones sociales causadas por el  personal temporal contratado directamente Profesional"
label var c3r4c1 "Costos y gastos de productos elaborados por terceros, PRODUCCION"
label var c3r4c2 "Sueldos, salarios y prestaciones sociales causadas por el  personal temporal contratado directamente directivos, admon y ventas"
label var c3r4c3 "Total Costos y gastos de productos elaborados por terceros, TOTAL DE PRODUCCI�N Y DE ADMINISTRACI�N Y VENTAS"
label var c3r8pt "Valor causado por las empresas que sumistran personal temporal al establecimiento Profesionales"
label var c3r8c1 "Costos producc. - Arrendamiento inmuebles"
label var c3r8c2 "Gastos Admon - Arrendamiento inmuebles"
label var c3r8c3 "Total costos - Arrendamiento inmuebles"
label var c3r10pt "TOTAL  costos y gastos causados por el personal ocupado PROFESIONALES"
label var c3r10c1 "Gastos Producc - Seguros"
label var c3r10c2 "Gastos Admon - Seguros"
label var c3r10c3 "Total seguros"
label var c3r35c1 "TOTAL  otros costos y gastos de la actividad industrial PRODUCCION"
label var c3r35c2 "TOTAL  otros gastos de la actividad industrial ADMINISTRACION Y VENTAS"
label var c3r35c3 "TOTAL  otros gastos de la actividad industrial produccion + ADMINISTRACION Y VENTAS"
label var c7r10c1 "Valorizaciones y desvalorizaciones, TERRENOS."
label var c7r10c6 "Valorizaciones y desvalorizaciones, EQUIPO DE TRANSPORTE."
label var c7r10c7 "Total Valorizaciones y desvalorizaciones, TOTAL."
label var c6r5c1 "Total a diciembre (2005)"
label var c6r5c3 "Valor inventarios al finalizar el a�o"
label var activfi "activos fijos"
label var consin "otros gastos"
label var consin2 "consumo intermedio"
label var consmate "consumo de materias"
label var deprecia "depreciaci�n"
label var eelec "energia electrica en kw"
label var invebrta "Inversi�n bruta"
label var inveneta "Inversi�n neta"
label var persocu "personal permanente"
label var persoesc "personal permanente + propietarios"
label var pertem3 "personal temporal directo"
label var pperytem "personal permanente + temporal directo"
label var pertotal "personal permanente + propietarios +personal temporal directo + temporal empresas "
label var prespyte "prestaciones sociales de permantente y temporal directo"
label var pressper "prestaciones de permantente"
label var prodbind "producci�n industrial"
label var prodbr2 "producci�n bruta"
label var salarper "salario de permanentes "
label var salpeyte "sueldos y salarios personal permanente y temporal"
label var valagri "valor agregado"
label var valvfab "VALOR de la producci�n"
label var valorven "VALOR de las ventas"
label var porcvt "Valor vendido al exterior"
label var numero_est "N�mero de establecimientos por empresa"

save panel_clean, replace








