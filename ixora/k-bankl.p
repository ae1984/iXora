/* k-bankl.p
 * MODULE
        СПРАВОЧНИКИ
 * DESCRIPTION
        Просмотр и ручное редактирование справочника банков
	<Insert> - вставка новой строки . <F4> - выход из режима вставки.
	<F10> или <CTRL D>- удалить строку.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
	5-10-1
 * AUTHOR
        31/12/99 pragma
 * CHANGES
	20/09/02 nataly - был добавлен признак "Рейтинг" поле bankl.lne
	05.05.05 u00121 - добавил обработку поля bankl.mntrm - Код основного терминала банка
    26/06/2008 madiyar - немножко переделал кривой интерфейс
        25.02.10 marinav - улучшена форма
        18.11.10 marinav - теперь признак bankl.nu не меняется на "i".
        19/08/2013 galina - ТЗ1871 добавила поля bankl.smepbank и bankl.smeptrm

*/



{mainhead.i}

def new shared var v-cbankl like bankl.bank.
def new shared var c-cbankl like bankl.bank.
def new shared var v-geo like geo.geo format "x(3)".

def var v-ans as logi.
def var ss as char format "x(10)" label "Банк" init "*".
def var v-br as char.
def var v-cl as char.
def var in_iso as char format "x(2)".

def buffer bb for bankl.



find sysc where sysc.sysc = "OURBNK" no-lock no-error. /* Office code */
if available sysc then
	v-br = sysc.chval.

find sysc where sysc.sysc = "CLCEN" no-lock no-error.  /* Clearing cent.code */
if available sysc then
	v-cl = sysc.chval.

update ss with side-label frame sss centered.

{bankl.f}
tab :
repeat:

{sbrw.i
&start = " "
&head = "bankl"
&headkey = "bank"
&where = " bankl.bank >= ss "
&index = "bank"
&formname = "bankln"
&framename = "bankln"
&addcon = "true"
&deletecon = "true"
&predelete = " if bankl.fid <> v-br then do :
                  Message 'Невозможно удалить  .'. next upper. end. "
&predisplay = " "
&precreate  = "v-cbankl = ' '. disp bankl.bank bankl.nu bankl.name bankl.addr
  				    bankl.attn bankl.tel bankl.lne bankl.fax bankl.tlx bankl.bic v-geo bankl.crbank
  				    bankl.acct bankl.chipno v-cbankl bankl.mntrm bankl.smepbank bankl.smeptrm with frame bankl no-hide."
&prechoose = "
		display 'Справочник банков' at 30 with no-hide row 3 column 13 width 98 frame f1. v-cbankl = bankl.cbank. v-geo = string(bankl.stn,'999' ).
 		in_iso = bankl.frbno.
		disp bankl.bank   bankl.nu bankl.name bankl.addr bankl.attn bankl.tel bankl.lne bankl.fax in_iso bankl.tlx  bankl.bic v-geo bankl.crbank bankl.acct
		     bankl.chipno v-cbankl bankl.mntrm bankl.smepbank bankl.smeptrm with frame bankl.
		displ '<C>правочники' with row 30 column 13 no-box no-hide frame fff . pause 0 . "
&display = "bankl.bank "
&highlight = "bankl.bank"
&postcreate = " "
&postdisplay = " "
&postadd = "update bankl.bank validate (bankl.bank <> ' ' , ' Ошибка ! ') with
            frame bankln. bankl.fid = v-br. disp bankl.bank with frame bankl. "
&postkey = " else if keyfunction(lastkey) = 'TAB' then do:
             hide all. ss = '*'. update ss with side-label frame ss centered .
             next tab. end.
             else if keylabel(lastkey) = 'C' or  keylabel(lastkey) = 'S '
              then
             do: hide frame fff.
                 run subcod(bankl.bank,'bnk') .
                 view frame bankln .
             end.
             "
&postupdate = " hide frame fff. if bankl.fid <> v-br and bankl.nu <> 'i' then do: Message ' Вы можете изменять только кор.счета !'. pause. end.
else do :
if v-br <> v-cl then do : display bankl.nu with frame bankl. pause 0. end.
else update bankl.nu help ' n - other banks, u - participants, i - internal banks ' with frame bankl.
update bankl.name bankl.addr bankl.attn  bankl.tel bankl.fax  bankl.tlx bankl.lne
in_iso validate(can-find(codfr where codfr.codfr eq 'iso3166' and codfr.code eq in_iso),"""")
bankl.bic
v-geo  validate(can-find(geo where int(geo.geo) = int(v-geo)),"""") bankl.crbank
validate (bankl.crbank <> ' ','Введите транспорт. адрес ') bankl.smepbank bankl.smeptrm with frame bankl.
bankl.stn = int(v-geo). bankl.frbno = in_iso.
update bankl.acct bankl.chipno with frame bankl.
repeat : c-cbankl = v-cbankl.
 update v-cbankl validate (v-cbankl <> '', 'Введите кор.банк ') with frame bankl .
 if bankl.bank = c-cbankl and c-cbankl <> v-cbankl then do :
 find first bb where bb.bank <> bankl.bank and bb.cbank = c-cbankl no-error.
 if available bb then do :
    message 'Correct other banks with cor.bank = ' c-cbankl '.' .
    pause. v-cbankl = c-cbankl. leave.
 end.
 else do : for each bankt where bankt.cbank = c-cbankl :
     delete bankt. end. end. end. if bankl.bank = v-cbankl then leave.
      find first bankt where bankt.cbank = v-cbankl no-lock no-error.
      if available bankt then leave.
      else Message 'Банк  ' v-cbankl ' не найден '.
      v-cbankl = bankl.cbank.
 end.
 bankl.cbank = v-cbankl. update bankl.mntrm with frame bankl. bankl.who = g-ofc. bankl.fid = v-br. end.
 if keyfunction(lastkey) = 'end-error' then next upper.
 run k-bankt. if keyfunction(lastkey) = 'end-error' then next upper. "
&end = " hide all. leave tab." }
end.
