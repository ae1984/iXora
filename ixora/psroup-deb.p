/* psroup-deb.p
с psroup-2.p
 * MODULE

 * DESCRIPTION
        Регистрация исход платежей в тенге (P) дебиторы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        out_P_db
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-3-3
 * AUTHOR
        18.09.2006 u00600 - автоматическое проставление реквизитов для п.8.3.3 - дебиторы
 * CHANGES
        22.09.2006 u00600 - формат ввода полей ИИК, БИК таблицы debls
        27.09.2006 u00600 - наименование формы c psror-2deb на psror-2 (возвращение к старой форме)
        27/11/2006 u00600 - по ТЗ ї 225 - if v-pnp begins '000941' (дебиторы)
        17.11.09 marinav счет as cha format "x(20)"
        04.12.09   marinav - добавились поля debls.acc bic
        25.01.2011 marinav - изменения в связи с переходом на БИН/ИИН
        18/11/2011 evseev  - переход на ИИН/БИН
        03.09.2012 evseev - иин/бин
*/
{comm-rnn.i}

/* для использования BIN */
{chk12_innbin.i}
{chbin.i}

function checkRNN returns logical (cRNN as char). /*u00600*/
    define variable cc as character.
    define variable ii as int.

    cc = trim (cRNN).
    do ii = 1 to length (cc):
       /* любое число, чтобы была ошибка */
       if lookup (substring(cc, ii, 1), "0,1,2,3,4,5,6,7,8,9") = 0 then return true.
    end.
    if v-bin = yes then return not chk12_innbin(cRNN).
                   else return comm-rnn (cRNN).

end function.


{global.i}

def var v-chksts as integer no-undo.
def var l-ans    as   logical no-undo.
def var v-val as integer no-undo.


def buffer acrc for crc.
def buffer bcrc for crc.
def buffer ccrc for crc.
def buffer dcrc for crc.
def buffer zcrc for crc.

def shared var s-remtrz like remtrz.remtrz.
def shared var v-ref as cha format "x(10)".
def shared var v-pnp as cha format "x(20)".
def var acode like crc.code no-undo.
def var bcode like crc.code no-undo.
def var ccode like crc.code no-undo.
def var s-bank like bankl.bank no-undo.
def shared frame remtrz.
def shared var v-comgl as inte.
def shared var v-regnom as char format "x(12)".

def var prilist like sysc.chval no-undo.
def var amt1 like remtrz.amt no-undo.
def var amt2 like remtrz.amt no-undo.
def var amt3 like rem.amt no-undo.
def var amtp like rem.amt no-undo.

define buffer b-cif for cif.
define buffer b-aaa for aaa.
define buffer d-aaa for aaa.
define buffer d-cif for cif.
DEF buffer xaaa for aaa.
DEF var bila like aaa.cbal label "ОСТАТОК" no-undo.
def var com1 like rem.amt no-undo.
def var com2 like rem.amt no-undo.
def var com3 like rem.amt no-undo.
def var br as int format "9" no-undo.
def var sr as int format "9" no-undo.
def var ii as inte initial 1 no-undo.
def var pakal  as char no-undo.
def var v-sumkom like remtrz.svca no-undo.
def var v-uslug as char format "x(10)" no-undo.
def var ee1 like tarif2.num no-undo.
def var ee2 like tarif2.kod no-undo.
def var v-numurs as char format "x(10)" no-undo.
/*def shared var v-reg5 as char format "x(12)".*/
def shared var v-bin5 as char format "x(12)".
def new shared var ee5 as char format "x".
def new shared var s-aaa like aaa.aaa.
def var i6 as int no-undo.
def var tt1 as char format "x(60)" no-undo.
def var tt2 as char format "x(60)" no-undo.
def shared var v-chg as integer.
def var ourbank like bankl.bank no-undo.
def var sender as cha no-undo.
def var v-cashgl like gl.gl no-undo.
def var v-priory as cha format "x(8)" no-undo.
def var v-rnn as log no-undo.

def var s-cif as char no-undo.
def var s-rnn as char no-undo.

def var v-arp as char no-undo.

def shared var v-grp like debgrp.grp  label "Группа дебитора ".
def shared var v-ls like debls.ls.

{lgps.i}



/*{psror-2deb.f}*/   /*u00600*/
{psror-2.f}

{comchk.i}

def temp-table vgl
    field vgl as inte.
def var vgldes as char.

ee5 = "2" .

find last sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display " Запись OURBNK отсутствует в файле sysc !!".
  pause .
  undo .
  return .
end.
ourbank = sysc.chval.

find first sysc where sysc.sysc = "RMCASH" no-lock no-error .
  if not avail sysc then do:
      message " Запись RMCASH отсутствует в файле sysc . " .
      return.
  end  .
v-cashgl = sysc.inval .

find last sysc where sysc.sysc = "rmsvco" no-lock.
repeat:
  if entry(ii,sysc.chval) = "" then leave.
  create vgl.
  vgl.vgl = integer(entry(ii,sysc.chval)).
  ii = ii + 1.
end.


find last sysc where sysc.sysc = "REMBUY" no-lock no-error.
br = sysc.inval.
find last sysc where sysc.sysc = "REMSEL" no-lock no-error.
sr = sysc.inval.

find last sysc where sysc.sysc = 'PRI_PS' no-lock no-error .
if not avail sysc or sysc.chval = '' then do:
 display ' Запись PRI_PS отсутствует в файле sysc !! '.
  pause . undo . return .
  end.
else  prilist = sysc.chval.

do transaction :

find last remtrz where remtrz.remtrz = s-remtrz exclusive-lock.

if remtrz.svcaaa ne "" then  v-chg = 3 .
else
if remtrz.svcgl  ne 0  then  v-chg = 1 .
display v-chg with frame remtrz. pause 0 .
if remtrz.jh1 ne ? then return .
display remtrz.remtrz with frame remtrz .
pause 0 .
find dcrc where dcrc.crc = 1 no-lock.

if remtrz.rdt = ? then  remtrz.rdt = g-today.
    find first tarif2 where tarif2.str5 = string(remtrz.svccgr) and tarif2.stat = 'r' no-lock no-error .
    if avail tarif2 then pakal = tarif2.pakalp.
    display pakal with frame remtrz .
    pause 0 .

do on error undo,retry:

/*-------------------------------------------------------------------------------------------------*/

/* update v-grp validate (v-grp ne 0 ,"Введите номер группы! Помощь F2!") with frame remtrz.*/

  define frame dframe3 v-grp with row 3 centered 1 column side-labels overlay title "Дебитор".

  on help of v-grp in frame dframe3 do: run help-debgrp(true). end.

  update v-grp validate (v-grp ne 0 ,"Введите номер группы! Помощь F2!") with frame dframe3.
  hide frame dframe3.

  run trx-debcheck (input v-grp, output v-ls).

  if v-ls = ? or v-ls = 0 or not (can-find (debls where debls.grp = v-grp and debls.ls = v-ls))
                             then do: message "Ошибка! Не выбран дебитор." view-as alert-box buttons OK .
                                      undo,retry.
                             end.

 find first debls where debls.grp = v-grp and debls.ls = v-ls no-lock no-error.
 if avail debls and (debls.bic = "" or debls.acc = "" or debls.kbe = "") then do:
   message "Ошибка! У дебитора не заполнены поля." view-as alert-box buttons OK .

/*u00600------------------------------------------------------------------------------------------------------*/
define variable v-countnum as character format 'x(3)' label "Код страны".

define frame getsernum
       debls.name format "x(50)" label "Наименование" validate (debls.name <> "", "Введите наименование!")
       debls.rnn format "x(12)" label "РНН"
                 validate (debls.rnn = "" or (debls.rnn <> "" and not checkRNN (debls.rnn)), "Неправильный код РНН!")
       debls.ser format "x(5)" label "Серия св-ва"
                 validate (debls.ser = '' or length(debls.ser) = 5, "Длина серии св-ва должна быть 5 символов!")
       debls.num format "x(7)" label "Номер св-ва"
                 validate (debls.num = '' or length(debls.num) = 7, "Длина номера св-ва должна быть 7 символов!")
       /*debls.iik format ">>>>>>>>>9" label "ИИК" */
       debls.acc  label "ИИК"
       debls.bic  label "БИК"
       debls.kbe format "x(2)" label "КБЕ"
       with row 3 centered 1 column side-labels overlay title "Постановка на учет по НДС".
define frame getsernum1
       debls.name format "x(50)" label "Наименование" validate (debls.name <> "", "Введите наименование!")
       debls.rnn format "x(12)" label "ИИН/БИН"
                 validate (debls.rnn = "" or (debls.rnn <> "" and not checkRNN (debls.rnn)), "Неправильный код ИИН/БИН!")
       debls.ser format "x(5)" label "Серия св-ва"
                 validate (debls.ser = '' or length(debls.ser) = 5, "Длина серии св-ва должна быть 5 символов!")
       debls.num format "x(7)" label "Номер св-ва"
                 validate (debls.num = '' or length(debls.num) = 7, "Длина номера св-ва должна быть 7 символов!")
       /*debls.iik format ">>>>>>>>>9" label "ИИК" */
       debls.acc  label "ИИК"
       debls.bic  label "БИК"
       debls.kbe format "x(2)" label "КБЕ"
       with row 3 centered 1 column side-labels overlay title "Постановка на учет по НДС".

define frame getsernum2
       debls.name format "x(50)" label "Наименование" validate (debls.name <> "", "Введите наименование!")
       v-countnum
       with row 3 centered 1 column side-labels overlay title "Дебитор - нерезидент".


    find debgrp where debgrp.grp = debls.grp no-lock no-error.
    find arp where arp.arp = debgrp.arp no-lock no-error.
    find current debls no-error.
    v-countnum = debls.country.
    /* редактируем только резидентов */
    if arp.crc = 1 then do:

       update debls.name
              debls.rnn
              debls.ser
              debls.num
              debls.acc
              debls.bic
              debls.kbe
              with frame getsernum.

       hide frame getsernum.

    end.
    else do:
       update debls.name
              v-countnum
              with frame getsernum2.
       hide frame getsernum2.
       debls.country = v-countnum.
    end.
    find current debls no-lock no-error.
    v-countnum = ''.

 end.  /*if avail debls and (debls.bik = 0 or debls.iik = 0 or debls.kbe = "") then do:*/

/*u00600*/
 find first remdeb where remdeb.remtrz = s-remtrz exclusive-lock no-error.
 if avail remdeb then do:
   remdeb.grp = v-grp.
   remdeb.ls = v-ls.
 end.
 else do:
   create remdeb.
   assign remdeb.remtrz = s-remtrz.
          remdeb.grp = v-grp.
          remdeb.ls = v-ls.
 end.

/*-------------------------------------------------------------------------------------------------*/

 v-ref = substr(remtrz.sqn,19).
 update v-ref validate (v-ref ne "" ,"Введите номер платежного поручения!")
  with frame remtrz.
 remtrz.sqn = trim(ourbank) + "." + trim(remtrz.remtrz) + ".." + v-ref.

/* 07.06.2005 tsoy */

  find sub-cod where sub-cod.acc = remtrz.remtrz and
              sub-cod.sub = 'rmz'and
              sub-cod.d-cod = "urgency" no-lock no-error.

  if not avail sub-cod then
      v-priory = 'o'.
  else
      v-priory = sub-cod.ccode.

  displ  v-priory with frame remtrz.

  if m_pid = "P" then do:

      update v-priory with frame remtrz.

      find sub-cod where sub-cod.acc = remtrz.remtrz and
                  sub-cod.sub = 'rmz'and
                  sub-cod.d-cod = "urgency" exclusive-lock no-error.

      if not avail sub-cod then do:

      create sub-cod.
                  sub-cod.acc = remtrz.remtrz.
                  sub-cod.sub = 'rmz'.
                  sub-cod.d-cod = "urgency".
                  sub-cod.ccode = v-priory.
      end. else
                  sub-cod.ccode = v-priory.

      release sub-cod.

  end.

 /* suchkov - закоментировал проставление транспорта 3
    remtrz.cover = 3. */
/* rundoll - если платеж срочный то транспорт 2 */
if v-priory = "s" then remtrz.cover = 2.
                   else remtrz.cover = 1.
 display remtrz.cover with frame remtrz.

 disp remtrz.rdt
       with frame remtrz.
end.

MM:

do on error undo,retry:

    update remtrz.fcrc validate(can-find(crc where crc.crc = remtrz.fcrc) and ((remtrz.fcrc = 1 and m_pid = "P") or (remtrz.fcrc <> 1 and m_pid <> "P")), "") with frame remtrz.

    find acrc where acrc.crc = remtrz.fcrc and acrc.sts = 0 no-lock no-error.
        if not available acrc  then do:
            message "Статус валюты <> 0 " .
        undo, retry.
        end.

      acode = acrc.code. /*KZT*/
   disp acode with frame remtrz.

   update  remtrz.amt validate( remtrz.amt > 0 ,"") with frame remtrz.
   remtrz.info[6] = replace(remtrz.info[6],"payment","amt").
   if not remtrz.info[6] matches  "*amt*" then remtrz.info[6] =
   remtrz.info[6] + " amt".
   remtrz.amt = round ( remtrz.amt , acrc.decpnt ) .
   display remtrz.amt with frame remtrz.
   remtrz.payment = remtrz.amt.
   remtrz.tcrc = remtrz.fcrc.

   displ remtrz.tcrc with frame remtrz.

   find crc where crc.crc = remtrz.tcrc and crc.sts = 0 no-lock no-error.
   disp crc.code with frame remtrz.
   find ccrc where ccrc.crc = remtrz.tcrc no-lock.   /* new */
   remtrz.margb = 0. remtrz.margs = 0.

   find acrc where acrc.crc = remtrz.fcrc no-lock . /* new */
   find ccrc where ccrc.crc = remtrz.tcrc no-lock . /* new */
   find crc where crc.crc = remtrz.tcrc no-lock . /* new */

   if remtrz.fcrc eq remtrz.tcrc then  remtrz.payment = remtrz.amt.
   disp remtrz.payment with frame remtrz.
end.

do on error undo,retry:

   remtrz.outcode = 6. /*только арп-счета u00600*/
   displ remtrz.outcode with frame remtrz.

   if remtrz.outcode = 6 then do:

          find first debgrp where debgrp.grp = v-grp no-lock no-error.
          if avail debgrp then v-pnp = debgrp.arp.
          else v-pnp = ''.

          update v-pnp with frame remtrz.
          find arp where arp.arp = v-pnp no-lock no-error.
          if not available arp then do:
             bell.
             {mesg.i 2203}.
             undo,retry.
          end.
          else do:
           remtrz.dracc = v-pnp.
            remtrz.sacc = v-pnp .
           remtrz.drgl = arp.gl.
          end.
          if arp.crc ne remtrz.fcrc then do:
             bell.
             {mesg.i 9813}.
             undo,retry.
          end.

          def var v-d1 as date no-undo. def var v-d2 as date no-undo.
          def var v-GK like gl.gl no-undo. def var v-KR as char no-undo.
          def var v-dep as char no-undo. def var v-np as char format "x(45)" no-undo.
          def var v-acc like jl.acc no-undo.

          def var v-amt as decimal init 0 no-undo. def var v-period as integer init 0 no-undo.
          v-d1 = g-today .  /*date(integer(01),integer(01),year(g-today)).*/

          find first debls where debls.grp = v-grp and debls.ls = v-ls no-lock no-error.
          if avail debls then do: v-GK = debls.gl. v-KR = debls.code-R. v-dep = debls.code-dep. v-np = debls.np . end.

          define button dbut1 label "OK".
          define button dbut2 label "Отмена".
          define frame GK
               v-d1 format "99/99/9999" label "Период услуг с "  v-d2 format "99/99/9999" label "по "  validate (v-d2 >= v-d1, " Дата не может быть меньше " + string (v-d1))
               v-GK label "счет ГК"  validate (can-find (gl where gl.gl = v-GK and gl.gl <> 0), "Не найден счет ГК!")
               v-KR label "код расходов"  /*validate (can-find (cods where cods.code = v-KR and cods.gl = v-gk  and cods.arc = no no-lock) or v-kr = ?, "Не найден код расходов!")*/
               v-dep label "код департамента" v-np label "назнач.платежа"
               skip
               dbut1 dbut2
               with row 5 centered side-labels overlay.

          on help of v-gk in frame gk do:

          {itemlist.i
               &file = "gl"
               &frame = "row 5 centered scroll 1 12 down overlay "
               &where = " true "
               &flddisp = " gl.gl /*label 'КОД' format 'x(3)'*/
                            gl.des /*t-ln.name label 'НАЗВАНИЕ' format 'x(70)'*/
                            gl.subled
                            gl.level format 'z9'
                           "
               &chkey = "gl"
               &chtype = "integer"
               &index  = "gl"
               &end = "if keyfunction(lastkey) = 'end-error' then return."
          }

          v-gk = gl.gl.
          displ v-gk with frame gk.

          end.

          on help of v-KR in frame GK do:
             run help-code (v-GK:screen-value,v-acc).
             v-KR:screen-value = return-value.
             v-KR = v-KR:screen-value.
          end.

          on help of v-dep in frame GK do:
            run help-dep("000").
            v-dep:screen-value = return-value.
            v-dep = return-value.
          end.

          on choose of dbut1 in frame GK do:
           /*создать таблицу куда занесем все данные для последующего списания*/
           v-d1 = date(v-d1:screen-value). v-d2 = date(v-d2:screen-value). v-GK = integer(v-GK:screen-value).
           v-KR = string(v-KR:screen-value).

           v-period = (v-d2 - v-d1) / 30. v-amt = remtrz.amt / v-period.
           v-np = v-np:screen-value.

        /*message v-np view-as alert-box.*/

           find first debujo where debujo.remtrz = remtrz.remtrz no-lock no-error.
           if not avail debujo then do:

             create debujo.
             assign debujo.grp      = v-grp
                    debujo.ls       = v-ls
                    debujo.remtrz   = remtrz.remtrz
                    debujo.amt      = remtrz.amt
                    debujo.amt-m    = v-amt
                    debujo.crc      = remtrz.fcrc
                    debujo.gl       = v-GK
                    debujo.arp      = v-pnp
                    debujo.period   = v-period
                    debujo.dat1     = v-d1
                    debujo.dat2     = v-d2
                    debujo.code-R   = v-KR
                    debujo.code-dep = v-dep
                    debujo.np       = v-np.
             release debujo.
            end. /*if not avail debujo then do:*/
            apply "go" to frame gk.
          end.

            /* отменить и выйти из редактирования */
           on choose of dbut2 in frame GK do:
             apply "go" to frame gk.
           end.

            enable all with frame GK.
            pause 0.
            hide frame gk no-pause.

            remtrz.ord = arp.des .
            if remtrz.ord = ? then do:
               run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "psroup-deb.p 513", "1", "", "").
            end.
            /*v-reg5 = "" .*/
            display v-bin5 /*v-reg5*/ with frame remtrz . pause 0 .
            {updtord-533.i}

   end.

 end.

update remtrz.detpay[1] go-on("return") with frame detpay .


find first ptyp where  remtrz.ptype = ptyp.ptype no-lock no-error .
if not avail ptyp then remtrz.ptype = "N" .

remtrz.valdt1 = g-today .

remtrz.chg = 7.     /*   to  outgoing process     */
run d-subcod(s-remtrz,'rmz').

if keyfunction(lastkey) eq "end-error" then
        repeat while lastkey ne -1 :
         readkey pause 0.
        end.

run rmzque .


  run chgsts(input "rmz", remtrz.remtrz, "new").
 if m_pid = "P" then do:
  find ofc where ofc.ofc eq g-ofc no-lock.
   remtrz.ref = 'PU' + string(integer(truncate(ofc.regno / 1000 , 0)),'9999')
  + '    ' + remtrz.remtrz + '-S' + trim(remtrz.sbank) +
   fill(' ' , 12 - length(trim(remtrz.sbank))) +
   (trim(remtrz.dracc) +
   fill(' ' , 10 - length(trim(remtrz.dracc))))
   + substring(string(g-today),1,2) + substring(string(g-today),4,2)
   + substring(string(g-today),7,2).
  end .
end.
