/* taxnkupd.p
 * MODULE
        Налоговые платежи
 * DESCRIPTION
        Редактирование файла НК
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
        02/12/05 marinav
 * CHANGES
    31/07/2006 u00568 Evgeniy добавил адрес и телефон.
    12/09/2006 u00568 Evgeniy добавил обработку visible
*/

{comm-txb.i}

def var s_rowid1 as rowid.
def var v_rnn as char init ''.
def var v_name as char init ''.
def var v_bank as char init ''.
def var v_tel as char init ''.
def var v_adr as char init ''.

def buffer btaxnk for taxnk.

DEFINE QUERY q1 FOR taxnk.
def var ourbank as char.
/*ourbank = comm-txb().*/


def browse b1
    query q1
    display
        taxnk.rnn label "РНН"
        taxnk.name label "Наименование" format 'x(50)'
        taxnk.visible label "Вид" format 'да/нет'
        with 13 down title "RNN".

def frame fr1
    b1
    help "F8-блокировать, ENTER-просмотреть"
    with centered overlay /*view-as dialog-box*/.

define frame fr-1 skip(1)
       v_bank label "Банк          " format "x(10)" help ""  skip
       v_rnn  label "РНН           " format "x(12)" help ""  skip
       v_name label "Название      " format "x(50)" help ""  skip
       v_adr  label "Адрес         " format "x(50)" help ""  skip
       v_tel  label "Телефон       " format "x(50)" help ""  skip(2)
       with side-label centered overlay row 5 title "Ввод данных :" .

    on return of b1 in frame fr1
    do:
       s_rowid1 = rowid(taxnk).
       v_rnn = taxnk.rnn.
       v_name = taxnk.name.
       v_bank = taxnk.bank.
       v_adr = taxnk.adr.
       v_tel = taxnk.tel.

       display v_bank  v_rnn v_name v_adr v_tel with frame fr-1.
       update v_bank v_rnn v_name v_adr v_tel with frame fr-1.
       do transaction:
         find first btaxnk where rowid(btaxnk) = s_rowid1 EXCLUSIVE-LOCK.
         if avail btaxnk then do:
           assign
             btaxnk.rnn = v_rnn
             btaxnk.name = v_name
             btaxnk.bank = v_bank
             btaxnk.adr = v_adr
             btaxnk.tel = v_tel
             .
         end.
         release btaxnk.
       end. /* tran */
       close query q1.
       open query q1 for each taxnk /* where taxnk.bank = ourbank*/.
       reposition q1 to rowid s_rowid1.
       browse b1:refresh().
       apply "value-changed" to browse b1.
        /*apply "endkey" to frame fr1.*/
    end.

    on "clear" of b1 in frame fr1
    do:
       s_rowid1 = rowid(taxnk).
       do transaction:
         find first btaxnk where rowid(btaxnk) = s_rowid1 EXCLUSIVE-LOCK.
         if avail btaxnk then do:
           assign
             btaxnk.Visible = not btaxnk.Visible
             .
         end.
       end. /* tran */
       close query q1.
       open query q1 for each taxnk /* where taxnk.bank = ourbank*/.
       reposition q1 to rowid s_rowid1.
       browse b1:refresh().
       apply "value-changed" to browse b1.
        /*apply "endkey" to frame fr1.*/
    end.


open query q1 for each taxnk /*where taxnk.bank = ourbank*/.

if num-results("q1")=0 then
do:
    MESSAGE "Записи не найдены."
          VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
                 TITLE "Не найден РНН".
    return.
end.

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.
/*return rnn.*/
