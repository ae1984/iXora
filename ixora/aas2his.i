/* aas2his.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        18.06.2012 evseev
 * BASES
        BANK
 * CHANGES
        25.07.2012 evseev ТЗ-1233
        17.09.2012 evseev ТЗ-1445
*/


procedure aas2his.
   def buffer buffer-aaa for {&db}.aaa.
   def buffer buffer-cif for {&db}.cif.
   create {&db}.aas_hist.
   find first buffer-aaa where buffer-aaa.aaa = s-aaa no-lock.
   if avail buffer-aaa then do:
      find first buffer-cif where buffer-cif.cif = buffer-aaa.cif use-index cif no-lock no-error.
      if available buffer-cif then do:
         {&db}.aas_hist.cif = buffer-cif.cif.
         {&db}.aas_hist.name = trim(trim(buffer-cif.prefix) + " " + trim(buffer-cif.name)).
      end.
   end.
   assign
   {&db}.aas_hist.bnf      = {&db}.aas.bnf
   {&db}.aas_hist.dpname   = {&db}.aas.dpname
   {&db}.aas_hist.knp      = {&db}.aas.knp
   {&db}.aas_hist.kbk      = {&db}.aas.kbk
   {&db}.aas_hist.cif      = {&db}.aas.cif
   {&db}.aas_hist.irsts    = {&db}.aas.irsts
   {&db}.aas_hist.fnum     = {&db}.aas.fnum
   {&db}.aas_hist.docdat   = {&db}.aas.docdat
   {&db}.aas_hist.docdat1  = {&db}.aas.docdat1
   {&db}.aas_hist.docnum1  = {&db}.aas.docnum1
   {&db}.aas_hist.docnum   = {&db}.aas.docnum
   {&db}.aas_hist.docprim  = {&db}.aas.docprim
   {&db}.aas_hist.aaa      = {&db}.aas.aaa
   {&db}.aas_hist.ln       = {&db}.aas.ln
   {&db}.aas_hist.sic      = {&db}.aas.sic
   {&db}.aas_hist.chkdt    = {&db}.aas.chkdt
   {&db}.aas_hist.chkno    = {&db}.aas.chkno
   {&db}.aas_hist.chkamt   = {&db}.aas.chkamt
   {&db}.aas_hist.payee    = {&db}.aas.payee
   {&db}.aas_hist.expdt    = {&db}.aas.expdt
   {&db}.aas_hist.regdt    = {&db}.aas.regdt
   {&db}.aas_hist.who      = {&db}.aas.who
   {&db}.aas_hist.whn      = {&db}.aas.whn
   {&db}.aas_hist.tim      = {&db}.aas.tim
   {&db}.aas_hist.sta      = {&db}.aas.sta
   {&db}.aas_hist.del      = {&db}.aas.del
   {&db}.aas_hist.dtbefore = {&db}.aas.dtbefore
   {&db}.aas_hist.chgdat   = g-today
   {&db}.aas_hist.chgtime  = time
   {&db}.aas_hist.chgoper  = op_kod
   {&db}.aas_hist.docprim1 = {&db}.aas.docprim1
   {&db}.aas_hist.fsum     = {&db}.aas.fsum
   {&db}.aas_hist.bnfname  = {&db}.aas.bnfname
   {&db}.aas_hist.rnnben   = {&db}.aas.rnnben
   {&db}.aas_hist.bicben   = {&db}.aas.bicben
   {&db}.aas_hist.bankben  = {&db}.aas.bankben
   {&db}.aas_hist.iikben   = {&db}.aas.iikben
   {&db}.aas_hist.docprim  = {&db}.aas.docprim
   {&db}.aas_hist.nkbin    = {&db}.aas.nkbin
   {&db}.aas_hist.binben   = {&db}.aas.binben.
   {&db}.aas_hist.mn       = {&db}.aas.mn.
   {&db}.aas_hist.stadop   = {&db}.aas.stadop  .
   {&db}.aas_hist.kbe      = {&db}.aas.kbe     .
   {&db}.aas_hist.rmz      = "".
   {&db}.aas_hist.depart   = {&db}.aas.depart  .
   {&db}.aas_hist.point    = {&db}.aas.point   .
   {&db}.aas_hist.que      = {&db}.aas.que  .
   {&db}.aas_hist.rgref    = {&db}.aas.rgref.
   release {&db}.aas_hist.
end.

        /*aas.contr = True.
        aas.contrwho = g-ofc.*/



