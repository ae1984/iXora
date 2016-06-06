/* goadd_txb.p
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
        15.07.2010 k.gitalov
 * BASES
        BANK
 * CHANGES
        14.05.2013 damir - Внедрено Т.З. № 1731.
*/
def input param CurrTXB as char.
def input param iCif as char.
def input param GoCif as char.
def input param iG-ofc as char.
def input param iG-today as date.
def input param GoLogin as char.
def output param p-namefil as char.
def output param p-err as char.

def var i as inte.
def var v-acc as char.

def buffer b-sysc for txb.sysc.
   find b-sysc where b-sysc.sysc = 'OURBNK' no-lock no-error.
   if avail b-sysc then
   do:
    if b-sysc.chval = CurrTXB then
    do:
       def var Usr as class ClientClass_txb.
       Usr = NEW ClientClass_txb().
       if Usr:FindClientNo(iCif) then
       do:
         def var listacc as char.
         def var iAcc as char.
         listacc =  Usr:FindAcc().
         if INDEX(listacc,"|") > 0 then
         do:
           run sel1("Выберите счет",Usr:FindAcc()).
           iAcc = trim(return-value).
         end.
         else iAcc = listacc.

         if iAcc <> "" then
         do:
             find first comm.treasury where comm.treasury.isgo = false and comm.treasury.cif = iCif and comm.treasury.cifgo = GoCif and comm.treasury.login = GoLogin and comm.treasury.acc = iAcc no-lock no-error.
             if not avail comm.treasury then do:
               create comm.treasury.
               comm.treasury.isgo = false.
               comm.treasury.cifgo = GoCif.
               comm.treasury.txb = CurrTXB.
               comm.treasury.cif = iCif.
               comm.treasury.name = Usr:clientname.
               comm.treasury.acc = iAcc.
               comm.treasury.who = iG-ofc.
               comm.treasury.whn = iG-today.
               comm.treasury.login = GoLogin.
             end.
         end.
         p-namefil = Usr:clientname.
       end.
       else p-err = "Клиент не найден!".

	   if VALID-OBJECT(Usr)  then DELETE OBJECT Usr NO-ERROR .
    end.
   end.
   else do: message "Отсутствует переменная OURBNK!" view-as alert-box. end.









