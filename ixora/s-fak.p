/* s-fak.p
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
*/

define input parameter p-rg as integer.
define shared variable s-lon like lon.lon.
define shared variable g-today as date.
define shared variable rc as integer.
define new shared variable s-facif as character.
define new shared variable s-falon like falon.falon.
define variable s1   as decimal.
define variable s2   as decimal.
define variable s3   as decimal.
define variable s4   as decimal.
define variable s5   as decimal.
define variable i    as integer.
define variable j    as integer.
define variable k    as integer.
define variable l    as integer.
define variable m    as integer.
define variable min-lon as character.
define variable max-lon as character.
define variable var     as character.
define variable v-key   as character.
define variable ja      as logical.

define buffer falon1 for falon.

define new shared frame falon.

form falon.falon  format "x(13)"          label "Счет......."
     falon.facif  format "x(6)"           label "Покуратель."
     facif.name   format "x(50)"          label "Наименован."
     falon.opnamt format ">>>,>>>,>>9.99" label "Сумма......"
     validate(falon.opnamt >= falon.dam[1] - falon.cam[1],
              "Выданная сумма превышает договорную сумму !")
     falon.rdt    format "99/99/9999"     label "С.........."
     validate(falon.rdt >= lon.rdt and falon.rdt < lon.duedt,
              "Дата регистрации противоречива !")
     falon.duedt  format "99/99/9999"     label "По........."
     validate(falon.duedt > falon.rdt and falon.duedt <= lon.duedt,
              "Срок противоречив !")
     falon.prem   format ">9.9999"        label "Финанс. %.."
     with side-label 1 columns frame falon.


{ s-liz.i "NEW" }
define buffer bfacif for facif.

ON HELP of falon.facif IN FRAME falon
DO:
   run facifh.
   find first bfacif where bfacif.facif = cgFacifFacif no-lock no-error.
   if available bfacif then do:
      falon.facif = cgFacifFacif.
      s-facif = cgFacifFacif.
      display falon.facif with frame falon.
   end.
END.

ON INSERT of falon.facif IN FRAME falon
DO:
   run lnfacif.
   falon.facif = cgFacifFacif.
   display falon.facif with frame falon.
   view frame lon.
   view frame falon.
END.

rc = 1.
c1:
repeat:
   find lon where lon.lon = s-lon no-lock.
   find loncon where loncon.lon = s-lon no-lock.
   if lon.opnamt = ? or lon.opnamt <= 0
   then do:
        bell.
        message "Сумма договора !".
        pause.
        return.
   end.
   find first falon where falon.lon = lon.lon exclusive-lock no-error.
   if not available falon
   then do:
        create falon.
        falon.lon = lon.lon.
        falon.falon = lon.lon + "001".
        s-falon = falon.falon.
        falon.opnamt = 0. 
        falon.gl = lon.gl. 
        falon.rdt = g-today. 
        falon.who = userid('bank'). 
        falon.whn = g-today. 
        falon.duedt = lon.duedt. 
        falon.prem = 60. 
        falon.cif = lon.cif.
   end.
   s4 = lon.opnamt.
   for each falon where falon.lon = lon.lon no-lock:
       s4 = s4 - falon.opnamt.
   end.
   {s-edit1.i
     &rz         = "2"
     &var        = "var"
     &file       = "falon"
     &index      = "falon"
     &where      = "falon.lon = lon.lon"
     &i          = "i"
     &j          = "j"
     &n          = "1"
     &key        = "falon"
     &min-key    = "min-lon"
     &max-key    = "max-lon"
     &frame      = "falon"
     &postfind   = "l = integer(substring(falon.falon,11)). if trim(falon.facif)
      <> '' then do: find facif where facif.facif = falon.facif no-lock.
      display facif.name with frame falon. s-facif = facif.facif. s-falon =
      falon.falon. end. "
     &display    = "falon.falon falon.facif falon.opnamt falon.rdt falon.duedt
      falon.prem "
     &preupdate  = "
      if falon.dam[1] = 0 then do: 
         s-facif = ''. 
         update falon.facif with frame falon. 
         if s-facif <> '' then falon.facif = s-facif. 
         display falon.facif with frame falon. 
         if trim(falon.facif) <> '' then repeat: 
             find facif where facif.facif = falon.facif no-lock no-error. 
             if not available facif then do: 
               /*s-facif = falon.facif. run h-facif.*/ 
                 message 'Запись не найдена !'. pause no-message.
             end.
             leave. 
         end.
         else next. 
      end. else find facif where facif.facif = 
      falon.facif no-lock. display falon.facif facif.name with frame falon. s5
      = falon.opnamt. "
     &update     = "falon.opnamt falon.rdt falon.duedt falon.prem"
     &postupdate = "if frame falon falon.facif entered or frame falon 
      falon.opnamt entered or frame falon falon.rdt entered or frame falon
      falon.duedt entered or frame falon falon.prem entered then do: if 
      falon.opnamt - s5 > s4 then do: message 'Сумма превышает допустимую !'.
      falon.opnamt = s5. pause. end. s4 = s4 - (falon.opnamt - s5). falon.who =
      userid('bank'). falon.whn = g-today. end. "
      &dispkopa   = " "
     &predelete  = "find first falon1 where falon1.lon = lon.lon
      and falon1.falon <> falon.falon no-error. if not available falon1
      then undo,next c1.  find first fagra where fagra.falon = falon.falon
      and fagra.pf = 'F' no-error. if available fagra then undo,next c1. 
      v-key = falon.falon. "
     &postdelete = "for each fagra where fagra.falon = v-key:
      delete fagra. end. "
     &precreate  = "ja = no. message 'Прибавить новую запись ? (Y/N)'
      update ja. if not ja then undo,next c1. s1 = 0.
      for each falon1 where falon1.lon = lon.lon no-lock:
          s1 = s1 + falon1.opnamt. end. "
     &postcreate = "l = l + 1. falon.lon = lon.lon. falon.falon = lon.lon +
      string(l,'999'). s-falon = falon.falon. falon.opnamt = 0. falon.gl =
      lon.gl. falon.rdt = g-today. falon.who = userid('bank'). falon.whn =
      g-today. falon.duedt = lon.duedt. falon.prem = 60. falon.cif = lon.cif. "
     &end = " /* s1 = 0.
      for each falon1 where falon1.lon = lon.lon no-lock:
      s1 = s1 + falon1.opnamt. end. s2 = lon.opnamt.
      if s2 <> s1 then do: if s2 > s1 then do: find first falon where
      falon.lon = lon.lon exclusive-lock. falon.opnamt = 
      falon.opnamt + s2 - s1. end. else repeat while s1 <> s2:
      find first falon where falon.lon = lon.lon and 
      falon.opnamt - falon.dam[1] > 0 exclusive-lock. s3 = falon.opnamt -
      falon.dam[1]. if s3 >= s1 - s2 then do: falon.opnamt = falon.opnamt -
      (s1 - s2). s1 = s2. end. else do: falon.opnamt = falon.opnamt - s3.
      s1 = s1 - s3. end. end. end. */ "}.
   rc = 0.
   leave.
end.
