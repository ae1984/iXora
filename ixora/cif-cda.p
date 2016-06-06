/* cif-cda.p
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
        26.08.2004 tsoy  добавил поле GUARANTEE
        27.08.2004 tsoy  GUARANTEE изменил название на CLOSE DATE а также добавил возможность редактирования ранее не предусмотренное
        14.05.2009 galina - изменения для открытия 20-тизначных счетов, соотвествующих 9-тизначным
        02/11/2009 galina - убрала услови на 02 ноября 2009 для 20ґтизначных счетов
*/


{global.i}

def shared var s-aaa like aaa.aaa.
def shared var s-cif like cif.cif.

def var vdaytm as int label "TERM (DAYS)".
def var vdays as int.
def var mbal like aaa.opnamt label "MATURE-VALUE".
def var vans as log initial false.
def var v-oldaccrued like aaa.accrued.
def var v-weekbeg as int.
def var v-weekend as int.
def var v-grduedt as date label "CLOSE DATE".

def shared var v-aaa9 as char.
def buffer b-aaa for aaa.
def buffer b-depogar for depogar.


find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.
{cif-cda.f}
find aaa where aaa.aaa eq s-aaa.

if not available aaa then do:
  bell.
  {mesg.i 8813}.
  undo, return.
end.
if /*(length(s-aaa) = 20 and g-today >= 11.02.2009) or*/ length(s-aaa) = 20 then do:
    if aaa.expdt eq ? then aaa.expdt = aaa.regdt.
    /*
    repeat:
      find hol where hol.hol eq aaa.expdt no-error.
      if not available hol and
       weekday(aaa.expdt) ge v-weekbeg and
       weekday(aaa.expdt) le v-weekend
      then leave.
      else aaa.expdt = aaa.expdt - 1.
    end.
    */
    
    vdaytm = aaa.expdt - aaa.regdt.
    if aaa.complex = true then
      mbal = aaa.opnamt * exp(1 + aaa.rate / aaa.base / 100 , vdaytm).
    else
      mbal = aaa.opnamt * (1 + aaa.rate * vdaytm / aaa.base / 100).
    
    find depogar where depogar.aaa = aaa.aaa no-lock no-error.
    if avail depogar then do:
        v-grduedt =  depogar.duedt. 
    end.
    
    display aaa.aaa aaa.cif
            aaa.regdt aaa.rate
            aaa.opnamt
            vdaytm aaa.expdt
            mbal
            v-grduedt.
    
            /*
            aaa.autoext
            aaa.rollover
            aaa.craccnt.
            */
    
    update aaa.regdt vdaytm.
    aaa.expdt = aaa.regdt + vdaytm.
    repeat:
      find hol where hol.hol eq aaa.expdt no-error.
      if not available hol and
       weekday(aaa.expdt) ge v-weekbeg and
       weekday(aaa.expdt) le v-weekend
      then leave.
      else aaa.expdt = aaa.expdt + 1.
    end.
    
    vdaytm = aaa.expdt - aaa.regdt.
    display vdaytm.
    update aaa.expdt.
    vdaytm = aaa.expdt - aaa.regdt.
    display vdaytm.
    /* ja 03/10/2001 to prohibit amending account parameters by not admins */
       find ofc where ofc.ofc = g-ofc no-lock.
       find lgr where lgr.lgr = aaa.lgr no-lock.
       if ofc.expr[5] matches "*a*" or lgr.led <> "CDA" then do:
             update aaa.rate.
       end.
             update aaa.opnamt. 
    /* End ja 03/10/2001 */        
    if aaa.complex = true then
      mbal = aaa.opnamt * exp(1 + aaa.rate / aaa.base / 100 , vdaytm).
    else
      mbal = aaa.opnamt
           * (1 + aaa.rate * vdaytm / aaa.base / 100).
    if aaa.regdt lt g-today then do:
      vdays = g-today - aaa.regdt.
      {mesg.i 0930} update vans.
      if vans eq false then undo, retry.
      vans = no.
      {mesg.i 750} update vans.
    
        if vans  then do:
            v-oldaccrued = aaa.accrued.
            if aaa.complex = true then
            aaa.accrued = aaa.opnamt * exp(1 + aaa.rate / aaa.base / 100 , vdays).
            else
                aaa.accrued = aaa.opnamt * aaa.rate * vdays / aaa.base / 100.
            if v-oldaccrued ne aaa.accrued then do:
    /*
              output to value(g-dbdir + "/" + "pm.err") append.
              put today space(1) string(time,"HH:MM:SS") space(1)
                  g-ofc " Change accrued for "
                  aaa.aaa " old "  v-oldaccrued " new " aaa.accrued skip.
              output close.
    */
              run savelog ("cif-cda", "Change accrued for " + string(aaa.aaa) + " old " +
                                      string (v-oldaccrued) + " new " + string(aaa.accrued)).
    
            end.
        end.
    end.
    
    update v-grduedt.
    
    find depogar where depogar.aaa = aaa.aaa no-error. 
    if not avail depogar then do:
          create depogar.
             depogar.aaa   = aaa.aaa.
             depogar.duedt = v-grduedt.
    end. else do:
          depogar.duedt = v-grduedt.
    end.
    
    display aaa.cif aaa.regdt aaa.rate aaa.expdt
       aaa.opnamt
       mbal.
    pause 10.
end.
/*
if (length(s-aaa) = 20 ) then do:
  find first b-aaa where b-aaa.aaa = v-aaa9 no-lock no-error.
  if avail b-aaa then do:    
     aaa.regdt = b-aaa.regdt.
     aaa.opnamt = b-aaa.opnamt.
     aaa.rate = b-aaa.rate.
     aaa.expdt = b-aaa.expdt.
  end.
  find first b-depogar where b-depogar.aaa = v-aaa9 no-lock.
  if avail b-depogar then do:
    find depogar where depogar.aaa = aaa.aaa no-error. 
    if not avail depogar then do:
      create depogar.
             depogar.aaa   = aaa.aaa.
             depogar.duedt = b-depogar.duedt.
    end. 
    else do:
          depogar.duedt = depogar.duedt.
    end.
    
  end.
end.
*/
/*
update aaa.rollover aaa.craccnt.
*/
