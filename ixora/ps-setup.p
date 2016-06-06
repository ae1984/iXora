/* ps-setup.p
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


{global.i}                                  
{ps-prmt.i}                                   

def var bs1 as cha format "x(70)". 
def var bs2 as cha format "x(70)" .
def buffer our for sysc.
def buffer clr for sysc.
def buffer lps for sysc.
def buffer err for sysc.
def buffer doc for sysc.
def buffer chg for sysc.
def buffer cash for sysc.
def buffer rogl for sysc.
def buffer ingl for sysc.
def buffer b-sub for sysc.
def buffer m-dir for sysc.
def buffer m-pri for sysc.
def buffer m-trx for sysc.
def buffer lb-trx for sysc.
def buffer h-prt for sysc.
def buffer h-prt1 for sysc.
def buffer d-cls for sysc.


find our where our.sysc = "ourbnk" exclusive-lock no-error .
if not avail our  then do:
 create our.
 our.sysc = "OURBANK".
end.

find h-prt where h-prt.sysc = "psphst" exclusive-lock no-error .
if not avail h-prt  then do:
 create h-prt.
 h-prt.sysc = "PSPHST".
end.

find h-prt1 where h-prt1.sysc = "ps1hst" exclusive-lock no-error .
if not avail h-prt1  then do:
 create h-prt1.
 h-prt1.sysc = "PS1HST".
end.

find clr where clr.sysc = "clcen" exclusive-lock no-error .
if not avail clr  then do:
 create clr.
 clr.sysc = "CLCEN".
end.

find lps where lps.sysc = "PS_LOG" exclusive-lock no-error .
if not avail lps  then do:
 create lps.
 lps.sysc = "PS_LOG".
end.

find err where err.sysc = "PS_ERR" exclusive-lock no-error .
if not avail err  then do:
 create err.
 err.sysc = "PS_ERR".
end.

find doc where doc.sysc = "PSDOC" exclusive-lock no-error .
if not avail doc  then do:
 create doc.
 doc.sysc = "PSDOC".
end.

find chg where chg.sysc = "pssvco" exclusive-lock no-error .
if not avail chg  then do:
 create chg.
 chg.sysc = "pssvco".
end.

find cash where cash.sysc = "rmcash" exclusive-lock no-error .
if not avail cash  then do:
 create cash.
 cash.sysc = "rmcash".
end.

find rogl where rogl.sysc = "pspygl" exclusive-lock no-error .
if not avail rogl  then do:
 create rogl.
 rogl.sysc = "pspygl".
end.

find ingl where ingl.sysc = "psingl" exclusive-lock no-error .
if not avail ingl  then do:
 create ingl.
 ingl.sysc = "psingl".
end.

find b-sub where b-sub.sysc = "PS_SUB" exclusive-lock no-error .
if not avail b-sub  then do:
 create b-sub.
 b-sub.sysc = "PS_SUB".
end.

find m-dir where m-dir.sysc = "M-DIR" exclusive-lock no-error .
if not avail m-dir  then do:
 create m-dir.
 m-dir.sysc = "M-DIR".
end.

find m-pri where m-pri.sysc = "PRI_PS" exclusive-lock no-error .
if not avail m-pri  then do:
 create m-pri.
 m-pri.sysc = "PRI_PS".
end.

find m-trx where m-trx.sysc = "PR-DIR" exclusive-lock no-error .
if not avail m-trx  then do:
 create m-trx.
 m-trx.sysc = "PR-DIR".
end.

find d-cls where d-cls.sysc = "PS-CLS" exclusive-lock no-error .
if not avail d-cls  then do:
 create d-cls.
 d-cls.sysc = "PS-CLS".
end.

find lb-trx where lb-trx.sysc = "LBNSTR" exclusive-lock no-error .
if not avail lb-trx  then do:
 create lb-trx.
 lb-trx.sysc = "LBNSTR".
end.





display
  " Код нашего банка       :"  our.chval skip 
  " Клиринговый   центр    :"  clr.chval skip
  " Дир. для протоколов    :"  lps.chval skip
  " Дир. для ошиб.сообщений:"  err.chval skip 
  " Дир. для документации  :"  doc.chval skip 
  " Г/К счет кассы         :"  cash.inval skip 
  " NOSTRO счет центробанка:"  lb-trx.chval skip 
  " Счет ГК для исх. платеж:"  rogl.inval   skip
  " Счет ГК для вход.платеж:" ingl.inval skip 
  " Счет ГК для комиссонных:" chg.chval skip 
  " Классификатор вход.плат:" b-sub.chval skip
  " Дир. для исход.платежей:" m-dir.chval skip 
  " Приоритеты             :" m-pri.chval skip 
  " Дир. для протоколов ПС :" m-trx.chval skip 
  " HOST принтера ПС       :" h-prt.chval skip 
  " HOST принтера протокол.:" h-prt1.chval skip 
  " Дата закрытого дня     :" d-cls.daval 
   with no-label width 78 centered frame st.

update our.chval with frame st.
update clr.chval with frame st.
update lps.chval with frame st.
update err.chval with frame st.
update doc.chval with frame st.
update cash.inval with frame st.
update lb-trx.chval with frame st.
update rogl.inval with frame st.
update ingl.inval with frame st.
update chg.chval with frame st.

 bs1 = substr(b-sub.chval,1,70) .
 bs2 = substr(b-sub.chval,71,70)  . 
update 
 bs1 bs2 
 with overlay centered row 10 no-label frame st1.
 b-sub.chval = trim(bs1) + bs2 . 
 hide frame st1 . 
display b-sub.chval with frame st. 

update m-dir.chval with frame st.
update m-pri.chval with frame st.
update m-trx.chval with frame st.
update h-prt.chval with frame st.
update h-prt1.chval with frame st.
 /*
update d-cls.daval with frame st.
   */
