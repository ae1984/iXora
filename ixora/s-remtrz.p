/* s-remtrz.p
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
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        12.07.2006 Тен      - убрал возможность редактирования документа
        10.06.2009 galina - добавила удаление из таблицы aaar при удалении платежа
        23.12.2010 id00004 - добавил message о запрете удаления платежей интернет-банкинга
        20/09/2011 dmitriy - добавил код и наименование КБК в поле "Назначение платежа"
                           - убрал возможность редактирования поля "Назначение платежа"
        25/11/2011 evseev - На основании ТЗ-1201 откатил изменения за 20/09/2011 dmitriy
        13.07.2012 Lyubov - перекомпиляция
        19.09.2012 Lyubov - добавлены зарплатные платежи
        06/08/2013 galina - ТЗ 1906 поправила определение типа платежа
*/

/* s-remout.p*/
{global.i}
def var ys as log format "Да/Нет".
def var kchoose as char .
def buffer tgl for gl.
def shared var v-option as cha .
def shared var s-remtrz like remtrz.remtrz .
def var t-pay like remtrz.amt.
def var prilist as cha.
define new shared frame remtrz.
def var acode like crc.code.
def var bcode like crc.code.
def var v-char like remtrz.cracc.
def var v-raz as int.
def var i as int.
{lgps.i}
{rmz.f}

 /* ten - проверка Сч.П и К.Сч на 9 знаков */
 for each remtrz where remtrz.remtrz = s-remtrz.

 if length (remtrz.racc) <> 9 and remtrz.racc <> "" then do:
            v-raz = 9 - length (remtrz.racc).
            do i=1 to v-raz:
                   v-char = v-char + "0".
            end.
    remtrz.racc = v-char + remtrz.racc.
 end.
   v-char = "".
   v-raz = 0.
 if length (remtrz.cracc) <> 9  and remtrz.cracc <> "" then do:
            v-raz = 9 - length (remtrz.cracc).
            do i=1 to v-raz:
                   v-char = v-char + "0".
            end.
    remtrz.cracc = v-char + remtrz.cracc.
 end.
end.

 find first remtrz where remtrz.remtrz = s-remtrz no-lock.
 find first que where que.remtrz = remtrz.remtrz no-lock no-error .
 if avail que then do:
 if ( que.con ne "W" or que.pid ne  m_pid  ) and m_pid ne "PS_"
  then do:
   Message "Невозможно обработать!" . pause .
   return.
   end.


 find first tarif2 where trim(tarif2.num) + trim(tarif2.kod) = string(remtrz.svccgr)
                     and tarif2.stat = 'r' no-lock no-error .
 if avail tarif2 then pakal = tarif2.pakalp .
  else pakal = ' ' .
 find gl where gl.gl = remtrz.drgl no-lock no-error.
 find tgl where tgl.gl = remtrz.crgl no-lock no-error.
 find crc where crc.crc = remtrz.fcrc no-lock no-error .
  if avail crc then acode = crc.code .
 find crc where crc.crc = remtrz.tcrc no-lock no-error .
  if avail crc then bcode = crc.code .
 t-pay = remtrz.margb + remtrz.margs .
 find first ptyp where ptyp.ptype = remtrz.ptype no-lock no-error.
 if avail ptyp then display ptyp.des with frame remtrz.
find sysc where sysc.sysc = 'PRI_PS' no-lock no-error .
if not avail sysc or sysc.chval = '' then do:
 display 'Отсутствует запись PRI_PS в таблице SYSC!'.
 pause . undo . return .
end.
prilist = sysc.chval.
find first que where que.remtrz = remtrz.remtrz no-lock no-error .
if avail que then
   v-priory = entry(3 - int(que.pri / 10000 - 0.5 ) ,prilist).
   else
   v-priory = entry(1,prilist) .
end .
do trans :
 run start.
 v-psbank = remtrz.sbank .
 if index(remtrz.rcvinfo[1],"/TAX/") <> 0 then
  v-kind = "Налог" .
  else
 if index(remtrz.rcvinfo[1],"/PSJ/") <> 0 then
 v-kind = "Пенсия" .
  else if index(remtrz.rcvinfo[1],"/ZP/") <> 0 then
 v-kind = "Зарплата" .
 else
  v-kind = "Норм." .

 display
     remtrz.remtrz remtrz.sqn  remtrz.rdt
     remtrz.valdt1  remtrz.valdt2 remtrz.jh1      remtrz.jh2
     v-psbank remtrz.rbank remtrz.scbank remtrz.rcbank
     remtrz.sacc remtrz.racc rsub
     remtrz.drgl remtrz.crgl remtrz.dracc  remtrz.cracc
     remtrz.fcrc acode remtrz.tcrc bcode remtrz.amt remtrz.payment
     remtrz.ptype remtrz.cover remtrz.svccgr  pakal
     remtrz.svca remtrz.svcrc remtrz.svcaaa remtrz.svccgl
     remtrz.bb remtrz.ba remtrz.bn remtrz.ord remtrz.bi  v-priory v-kind
     with frame remtrz .
     if avail tgl then  display tgl.sub with frame remtrz .
     if avail gl then  display gl.sub with frame remtrz .
   release remtrz .
   release que .
end .
kchoose = "".
if m_pid = "G" then do:
 find optlang where optlang.optmenu eq v-option and
   optlang.lang eq g-lang and optlang.menu = "OUTGOING" no-lock no-error.
  if avail optlang then kchoose = "OUTGOING".
end .
{subz.i
&choosekey = "keys kchoose auto-return "
&poschoose = "  kchoose = """" .  "
&head = remtrz
&headkey = remtrz
&framename = remtrz
&formname = rmz
&updatecon = true
&deletecon = true
&postrun = "

     find first doc_who_create where doc_who_create.docno = s-remtrz and doc_who_create.who_cr = g-ofc no-lock no-error.
     if not avail doc_who_create then do:
       create doc_who_create.
       doc_who_create.docno = s-remtrz.
       doc_who_create.who_cr = g-ofc.
     end.

     if m_pid ne  ""PS_"" then do:
     find first que where que.remtrz = s-remtrz
              no-lock no-error.
     if not avail que then return .
   if avail que and  not ( que.pid eq m_pid and que.con eq  ""W"" )
             then do: release remtrz.
             release que. return . end.  end  . "
&predelete = "
               find first que where que.remtrz = s-remtrz
               exclusive-lock no-error.
               find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock.
find last netbank where netbank.rmz = remtrz.remtrz no-lock no-error.
if avail netbank then do:
   Message "" Платежи Интернет-банкинга удалять запрещено, необходимо Отвергнуть или Акцептовать в п 2-2-5 (очередь 3A) "".
   release que . undo, retry.
end.

               if remtrz.jh1 ne ? then
                find first jl where jl.jh = remtrz.jh1 no-lock no-error .
               if remtrz.jh2 ne ? then
                find first jl where jl.jh = remtrz.jh2 no-lock no-error .
               if avail jl  or m_pid ne que.pid
                 or que.con ne ""W"" or que.pid = ""3"" then do:
                Message ""Невозможно удалить!"" . bell.
                release que . undo, retry.
               end. else do: run delnbal.
                if avail que then delete que . end . "
&postdelete = " find aaar where aaar.a1 = s-remtrz and aaar.a4 <> '1' exclusive-lock no-error.
                if avail aaar then do:
                  delete aaar.
                end.
                v-text = s-remtrz + "" удален "" . run lgps . "

&postupdate = "
    find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock  .
    if avail remtrz and remtrz.source = 'IBH' then do:
       message 'Доступ в данный пункт запрещен!' view-as alert-box information button ok.
    end.
    else  do:
    find first que where que.remtrz = s-remtrz no-lock no-error .

    if ( avail que and que.con ne ""F"" and que.pid = m_pid
     and  m_pid ne ""v1""  and  m_pid ne ""v2""
     and  m_pid ne ""3""  and  m_pid ne ""2L"" and m_pid ne ""31""
     and m_pid ne ""NC"" and m_pid ne ""3g"" and m_pid ne ""G"")
     or ( s-newrec) then
        do:
  find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock  .
  update remtrz.detpay[1] format 'x(35)' label 'Назначение платежа' skip
         remtrz.detpay[2] format 'x(35)' no-label skip
         remtrz.detpay[3] format 'x(35)' no-label skip
         remtrz.detpay[4] format 'x(35)' no-label with overlay top-only row 8 centered frame adsd.
  hide frame adsd.


  if remtrz.source = 'INK' then do:

      find first doc_who_create where doc_who_create.docno = s-remtrz exclusive-lock no-error.
      if not avail doc_who_create then do:
       create doc_who_create.
       doc_who_create.docno = s-remtrz.
      end.
      doc_who_create.ref = g-ofc.

     leave.
  end.

         run rotlxz .
         release remtrz.
         release que .
        end .
     else message ""У Вас нет прав делать это!"".
    find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error .
    find first que where que.remtrz = s-remtrz no-lock no-error .
    if not avail que then do:
     find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock  .
     delete remtrz .

     find first swout where swout.rmz = s-remtrz no-error.
     if avail swout then assign swout.deldate = today swout.deltime = time deluid = userid(""bank"").
     release swout.

     clear frame remtrz all . return . end .
    end.
" }

/* KOVAL добавил удaление remtrz в swift-базе swout */
