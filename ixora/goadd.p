/* goadd.p

 * MODULE
        
 * DESCRIPTION
        Корпоративное управление счетами филиалов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова 
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM  
 * AUTHOR
        15.07.2010 k.gitalov
 * CHANGES
        
*/

def input param CurrTXB as char.
def input param iCif as char.
def input param GoCif as char.
def input param iG-ofc as char.
def buffer b-sysc for bank.sysc.
       
   find b-sysc where b-sysc.sysc = 'OURBNK' no-lock no-error.
   if avail b-sysc then 
   do:
    if b-sysc.chval = CurrTXB then 
    do:
       def var Usr as class ClientClass.
       Usr = NEW ClientClass().
       if Usr:FindClientNo(iCif) then
       do:
         def var listacc as char.
         def var iAcc as char.
         listacc =  Usr:FindAcc(1).
         if INDEX(listacc,"|") > 0 then
         do:
           run sel1("Выберите счет", Usr:FindAcc(1)).
           iAcc = return-value.
         end.
         else iAcc = listacc.
	   	 
	   	 if iAcc <> "" then
	   	 do:
	   	    create comm.cashpool.
	   	        comm.cashpool.name = Usr:clientname.          
                if GoCif <> "" then
                do: 
                 comm.cashpool.isgo = false.
                 comm.cashpool.cifgo = GoCif.
                end.
                else comm.cashpool.isgo = true.
                comm.cashpool.txb = CurrTXB.
	            comm.cashpool.cif = iCif.
	            comm.cashpool.acc = iAcc.
	            comm.cashpool.who = iG-ofc.
	            comm.cashpool.rnn = Usr:rnn.  
	            
	            
	     end.     
	            
       end.
	         
	   if VALID-OBJECT(Usr)  then DELETE OBJECT Usr NO-ERROR .
    end.
   end.
   else do: message "Отсутствует переменная OURBNK!" view-as alert-box. end.

 
 


    