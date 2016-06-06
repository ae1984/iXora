/* pktnlist0.p
 * MODULE
        Кредиты
 * DESCRIPTION
   Формирование списка сотрудников у кого    
   есть кредиты к погашению через зарплату   
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
        29/10/2003 marinav исключены быстрые деньги (группы 90, 92)
        27/11/2003 sasco поиск сотрудников по таблицам tn и tnd (не было)
*/


/* {pktncif.i "shared"} */
{name2sort.i}
{comm-txb.i}

def var v-dt as date NO-UNDO.
def shared var seltxb as int NO-UNDO.

def shared var g-today as date.
def shared var vmc1 as integer.
def shared var vmc2 as integer.
def shared var vgod as integer.
def shared var sum11 as decimal.
def shared var v-name as char.
def shared var dt11 as date.
def shared var dt22 as date.

/*seltxb = comm-cod().*/

/*put stream rpt skip 
     " СВОД НАЧИСЛЕНИЙ/УДЕРЖАНИЙ ПО КОДАМ (всего) ПО ДЕПАРТАМЕНТУ " + v-name format 'x(80)' at 8  skip
         " ЗА "  + string(vgod) + " г. ( " + string(vmc1) + " - " + string(vmc2) + " )" format 'x(40)'  at 20.
  */
find pd  where pd.pdnos matches '*'+ v-name + '*' no-lock no-error.
if avail pd then do: 

FOR EACH alga.tekrg where tekrg.god = vgod 
    and tekrg.mc >= vmc1 and tekrg.mc <= vmc2 and tekrg.pd =  pd.pd no-lock
    BREAK by tekrg.schi by tekrg.sch:  
    accumulate tekrg.summa (sub-total by tekrg.schi by tekrg.sch).

if last-of(alga.tekrg.sch) and tekrg.sch < 360 then do:  
 find first sch where sch.sch=tekrg.sch no-lock no-error.
/* PUT stream rpt skip tekrg.sch format "zz9." at 8 sch.schnos at 13 format "x(40)" 
     accum total by tekrg.sch tekrg.summa at 54 format "zzz,zzz,zzz,zz9.99-".*/
end.
if last-of(alga.tekrg.schi) and tekrg.sch < 360 then
 sum11 = accum total by tekrg.schi tekrg.summa.
/*  PUT  stream rpt skip(1)
         "...............................ВСЕГО " at 1  
   sch.uz-iet format "x(10)" ": "  
   accum total by tekrg.schi tekrg.summa  at 54 format "zzz,zzz,zzz,zz9.99-"
     skip(1). */
end. 
end. /*avail pd*/
else message 'Данного департамента ' + v-name + ' нет в БД Зарплаты !!!'.


