/* ComPayDocFrame.i
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
        24.02.2009 k.gitalov
 * CHANGES
*/
/***************************************************************************************************************/                                         /* все что относится к отрисовке формы документов коммунальных платежей */

define variable acclab as char format "x(20)"   init "                   :".
define variable phonelab as char format "x(20)" init "                   :".
define variable addrlab as char format "x(20)"  init "                   :".
define variable payacc as char format "x(12)".
define variable bnamelab as char format "x(19)" init "Банк получателя   :".
define variable iiklab as char format "x(4)"    init "ИИК:".

 DEFINE FRAME MainFrame 
         skip (1)
         docNo as char label  "Номер документа"         space(15)  docJH as char label  "Номер проводки" skip
         suppname as char label  "Получатель платежа" FORMAT "x(30)" knp AS char FORMAT "x(3)" label "КНП" skip 
         bnamelab no-label suppbname AS character FORMAT "x(30)" no-label iiklab no-label suppiik as char  FORMAT "x(21)" no-label  skip 
         "_____________________________________________________________________________" skip(1)
         payname AS character FORMAT "x(35)" label "Плательщик  " 
         payrnn AS character FORMAT "999999999999" label " РНН" skip
         "_____________________________________________________________________________" skip(1)
         
                   
         acclab no-label payacc no-label  phonelab no-label payphone AS character FORMAT "x(8)" no-label  skip 
         addrlab no-label payaddr AS character FORMAT "x(45)" no-label skip
        
         summ AS decimal FORMAT "z,zzz,zzz,zzz,zz9.99-" label      "Сумма платежа      " skip
         "_____________________________________________________________________________" skip(1)
         comm_summ AS decimal FORMAT "z,zzz,zzz,zzz,zz9.99-" label "Комиссия банка     " skip
         summall AS decimal FORMAT "z,zzz,zzz,zzz,zz9.99-" label   "Общая сумма платежа" skip(2)
 WITH SIDE-LABELS centered overlay row 8 TITLE "Прием коммунальных платежей".
 
 
procedure ShowFrame:
           def input param Doc as COMPAYDOCClass.

           if Doc:docNo = ? then docNo = "00000000".
           else docNo = string(Doc:docNo,"99999999").
           
           if Doc:jh = ? then docJH = "000000".
           else docJH = string(Doc:jh,"999999").
           
           suppname  = Doc:suppname.
           suppiik   = Doc:suppiik.
           knp       = Doc:knp.
           suppbname = Doc:suppbname.
           payname   = CAPS(Doc:payname).
           payrnn    = Doc:payrnn.
           payacc    = Doc:payacc.
           payphone  = Doc:payphone.
           payaddr   = CAPS(Doc:payaddr).
           summ      = Doc:summ.
           comm_summ = Doc:comm_summ.
           if Doc:summ = 0 then summall = 0.
           else summall   = Doc:summ + Doc:comm_summ.
           
           
   
          case Doc:type:
            when 1 then
            do: /*Казахтелеком*/
               acclab   = "Лицевой счет       :".
               phonelab = "           Телефон :".
               addrlab  = "Адрес              :".
               DISPLAY docNo docJH suppname  iiklab suppiik knp  bnamelab suppbname 
                       payname payrnn 
                       acclab payacc  
                       phonelab payphone
                       addrlab payaddr
                       summ comm_summ summall WITH  FRAME MainFrame.
            end.
            when 2 then
            do: /*Dalacom, Pathword, NEO, City*/
               acclab = "Номер телефона     :".
               DISPLAY docNo docJH suppname knp 
                       payname payrnn  
                       acclab payacc  
                       summ comm_summ summall WITH  FRAME MainFrame.
            end.
            when 3 then
            do: /*Alma TV, Digital TV, ICON*/
               acclab = "Номер контракта    :".
               DISPLAY docNo docJH suppname knp 
                       payname payrnn  
                       acclab payacc 
                       summ comm_summ summall WITH  FRAME MainFrame.
            end.
          end case. 
        
      
end procedure. 


        