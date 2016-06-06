/* taxdlf.p
 * MODULE
        Налоговые платежи
 * DESCRIPTION
        Программа смены получателя на квитанцию
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
        26/07/04 kanat
 * CHANGES
*/

{comm-txb.i}
{get-dep.i}

def input parameter rid as rowid.

def var ourbank as char no-undo.
def var ourcode as integer no-undo.

def var i as integer. 

def var dat as date.

def buffer btax for tax.

def var cdate as date no-undo.
def var ctime as int no-undo.
def var ctxb as int no-undo.
def var cdnum as int no-undo.
def var cuid as char no-undo.
def var crnn as char no-undo.
def var crnnnk as char no-undo.
def var ccreated as int no-undo.

define variable docdnum as int.
define variable docuid as char.

ourbank = comm-txb().
ourcode = comm-cod().

do transaction:

            find first tax where rowid(tax) = rid no-lock no-error.

            rid = rowid(comm.tax).
            docdnum = tax.dnum.
            docuid = tax.uid.

            find first btax where rowid(btax) = rid no-lock no-error.

            dat = btax.date.

            {comdelpay.i 
             &tbl = "tax"
             &tbldate = "date"
             &tbluid = "uid"
             &tbldnum = "dnum"
             &tblwhy = "delwhy"
             &tblwdnum = "deldnum"
             &tbldeluid = "duid"
             &tbldeldate = "deldate"

             &whylist = "4"

             &tblrnn = "rnn"
             &tblsum = "sum"

             &exceptRNN = " chval dnum created edate etim euid valid rnn "
             &exceptALL = " chval dnum created edate etim euid "
             &exceptSUM = " chval dnum created edate etim euid sum comsum decval comcode "

             &wherebuffer = " tax.created < buftable.created "

             &whereSum   = " tax.rnn = buftable.rnn and 
                             tax.rnn_nk = buftable.rnn_nk and 
                             tax.kb = buftable.kb and 
                             tax.sum <> buftable.sum and
                             tax.bud = buftable.bud and
                             tax.comu = buftable.comu and
                             tax.tns = buftable.tns and
                             tax.colord = buftable.colord
                             "
             
             &whereRNN   = " tax.rnn <> buftable.rnn and 
                             tax.rnn_nk = buftable.rnn_nk and 
                             tax.kb = buftable.kb and 
                             tax.sum = buftable.sum and
                             tax.bud = buftable.bud and
                             tax.comu = buftable.comu and
                             tax.tns = buftable.tns and
                             tax.colord = buftable.colord
                             "
             
             &whereAll   = " tax.rnn = buftable.rnn and 
                             tax.rnn_nk = buftable.rnn_nk and 
                             tax.kb = buftable.kb and 
                             tax.sum = buftable.sum and
                             tax.bud = buftable.bud and
                             tax.comu = buftable.comu and
                             tax.tns = buftable.tns and
                             tax.colord = buftable.colord
                             "

             &olddate = "dat"
             &oldtxb = "ourcode"
             &olduid = "docuid"
             &olddnum = "docdnum"

             &where = " tax.rnn = btax.rnn and tax.rnn_nk = btax.rnn_nk and tax.created = btax.created  "
            }
            

            find first tax where tax.txb = btax.txb and
                                 tax.date = btax.date and 
                                 tax.uid = btax.uid and
                                 tax.created = btax.created and
                                 tax.dnum = btax.dnum and
                                 tax.rnn = btax.rnn and
                                 tax.rnn_nk = btax.rnn_nk and
                                 tax.duid = ?
                                 exclusive-lock no-error.
            find btax where rowid(btax) = rowid(comm.tax) no-lock no-error.
            assign cdate = btax.date
                   ctime = btax.created
                   cdnum = btax.dnum
                   ctxb  = btax.txb
                   cuid = btax.uid
                   crnn = btax.rnn
                   crnnnk = btax.rnn_nk
                   ccreated = btax.created
                   no-error.

            assign 
                tax.duid = userid('bank')
                tax.deltime = time.

            do i = 2 to 5:
               find next tax where tax.txb = ctxb and
                                   tax.date = cdate and 
                                   tax.uid = cuid and
                                   tax.created = ctime and
                                   tax.dnum = cdnum and
                                   tax.rnn = crnn and
                                   tax.rnn_nk = crnnnk and
                                   tax.duid = ? and
                                   tax.created = ccreated
                                   exclusive-lock no-error.
               if avail tax then
               assign 
                     tax.duid = userid('bank')
                     tax.deltime = time.
            end.

            release tax.

end. /* do transaction ... */ 
