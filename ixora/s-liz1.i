/* s-liz1.i
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

/*
* s-liz1.i
* Include file for s-liz file
* S.Kuzema 06.08.98
*/
cFacifFacif   = facif.facif.
cFacifName    = facif.name.
cFacifAddr    = facif.addr[1].
if num-entries(facif.tel) > 0 then do:
   if num-entries(facif.tel) > 1 then do:
      cFacifTel1    = entry(1,facif.tel).
      cFacifTel2    = entry(2,facif.tel).
   end.
   else cFacifTel1  = entry(1,facif.tel).
end.
else do:
   cFacifTel1    = "".
   cFacifTel2    = "".
end.
cFacifFax        = facif.fax[1].
cFacifBanka      = facif.banka.
cFacifKonts      = facif.konts.
cFacifFanrur     = facif.fanrur.
cFacifPvnMaks    = facif.rez-char[1].
cFacifVaditais   = facif.vad-amats.
cFacifVadUzvards = facif.vad-vards.
cFacifGrUzvards  = facif.gal-gram.
