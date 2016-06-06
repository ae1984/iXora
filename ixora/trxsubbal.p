/* trxsubbal.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        26/11/03 nataly добавлена обработка subledger SCU
        18/04/06 nataly добавлена обработка subledger TSF
*/

def input parameter vsub as char.
def input parameter vacc as char.
def input parameter vlev as inte.
def input parameter vcrc as inte.
def output parameter vdam like jl.dam.
def output parameter vcam like jl.cam.
def output parameter vvavl as deci.

def var vbal like jl.dam.
def var vavl like jl.dam.
def var vhbal like jl.dam.
def var vfbal like jl.dam.
def var vcrline like jl.dam.
def var vcrlused like jl.dam.
def var vooo like aaa.aaa.

vavl = 0.
vdam = 0.
vcam = 0.

if vsub = "ock" then do:
 find ock where ock.ock = vacc exclusive-lock no-error.
 if not available ock then return.
 find trxbal where trxbal.subled = vsub 
                  and trxbal.acc = vacc 
                  and trxbal.level = vlev 
                  and trxbal.crc = vcrc no-lock no-error.
         if not available trxbal then return.
         vdam = trxbal.dam.
         vcam = trxbal.cam.
end.
if vsub = "arp" then do:
 find arp where arp.arp = vacc exclusive-lock no-error.
 if not available arp then return.
    find trxbal where trxbal.subled = vsub 
                  and trxbal.acc = vacc 
                  and trxbal.level = vlev 
                  and trxbal.crc = vcrc no-lock no-error.
         if not available trxbal then return.
         vdam = trxbal.dam.
         vcam = trxbal.cam.
end. 
if vsub = "ast" then do:
 find ast where ast.ast = vacc exclusive-lock no-error.
 if not available ast then return.
  find trxbal where trxbal.subled = vsub 
                  and trxbal.acc = vacc 
                  and trxbal.level = vlev 
                  and trxbal.crc = vcrc no-lock no-error.
   if not available trxbal then return.
   vdam = trxbal.dam.
   vcam = trxbal.cam.
end. 

else if vsub = "cif" then do:
 find aaa where aaa.aaa = vacc exclusive-lock no-error.
 if not available aaa then return.
 if vlev = 1 then do:
    run aaa-bal777(aaa.aaa, output vbal, output vavl, output vhbal,
               output vfbal, output vcrline, output vcrlused, output vooo).
    vvavl = vavl.
 end.
 else do:
     find trxbal where trxbal.subled = vsub 
                  and trxbal.acc = vacc 
                  and trxbal.level = vlev 
                   and trxbal.crc = vcrc no-lock no-error.
         if not available trxbal then return.
         vdam = trxbal.dam.
         vcam = trxbal.cam.
 end.
end. 
if vsub = "eps" then do:
 find eps where eps.eps = vacc exclusive-lock no-error.
 if not available eps then return.
 find trxbal where trxbal.subled = vsub 
                  and trxbal.acc = vacc 
                  and trxbal.level = vlev 
                   and trxbal.crc = vcrc no-lock no-error.
         if not available trxbal then return.
         vdam = trxbal.dam.
         vcam = trxbal.cam.
end. 
if vsub = "fun" then do:
 find fun where fun.fun = vacc exclusive-lock no-error.
 if not available fun then return.
    find trxbal where trxbal.subled = vsub 
              and trxbal.acc   = vacc 
              and trxbal.level = vlev 
              and trxbal.crc   = vcrc 
              no-lock no-error.
         if not available trxbal then return.
         vdam = trxbal.dam.
         vcam = trxbal.cam.
end. 
 /*26/11/03 nataly*/
if vsub = "scu" then do:
 find scu where scu.scu = vacc exclusive-lock no-error.
 if not available scu then return.
    find trxbal where trxbal.subled = vsub 
              and trxbal.acc   = vacc 
              and trxbal.level = vlev 
              and trxbal.crc   = vcrc 
              no-lock no-error.
         if not available trxbal then return.
         vdam = trxbal.dam.
         vcam = trxbal.cam.
end. 
/*26/11/03 nataly*/
if vsub = "tsf" then do:
 find tsf where tsf.tsf = vacc exclusive-lock no-error.
 if not available tsf then return.
    find trxbal where trxbal.subled = vsub 
              and trxbal.acc   = vacc 
              and trxbal.level = vlev 
              and trxbal.crc   = vcrc 
              no-lock no-error.
         if not available trxbal then return.
         vdam = trxbal.dam.
         vcam = trxbal.cam.
end. 
/*18/04/06 nataly*/
if vsub = "lon" then do:
 find lon where lon.lon = vacc exclusive-lock no-error.
 if not available lon then return.
 find trxbal where trxbal.subled = vsub 
  and trxbal.acc = vacc 
  and trxbal.level = vlev 
  and trxbal.crc = vcrc 
  no-lock no-error.
 if not available trxbal then return.
  vdam = trxbal.dam.
  vcam = trxbal.cam.
end. 



