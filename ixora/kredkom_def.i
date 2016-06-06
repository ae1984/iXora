/* kredkom_def.i
 * MODULE
        Кредитный Модуля
 * DESCRIPTION
        Анализ кредитного портфеля
 * RUN
        kredkom3(d1)
 * CALLER
        r_krcom1.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        16/09/2005 saltanat
 * CHANGES
*/

def input parameter d1 as date.
def shared var g-ofc as char.
def shared var g-today as date.
def var rat as decimal.
def var long as int init 0.
def new shared var bilance   as decimal format '->,>>>,>>>,>>9.99'.
def var dlong as date.
def var srok as deci.
def var dat1 as date.
def var dat2 as date.
def var dat3 as date.
def var v-dat as date.
def var otrasl as char.
def var v-obes as char.
def var v-prolon as integer init 0.
def var v-rate as decimal.
def var v-dolg as decimal.
def var v-sum as decimal format '->,>>>,>>>,>>9.99'.
def var v-sumt as decimal format '->,>>>,>>>,>>9.99'.
def var v-gar as deci.
def var vbal as deci.
def buffer baaa for txb.aaa.

def shared temp-table  wrk
    field lon    like txb.lon.lon
    field grp    like txb.lon.grp
    field cif    like txb.cif.cif
    field name   like txb.cif.name
    field gua    like txb.lon.gua
    field segm   as char
    field amoun  like txb.lon.opnamt
    field aaa1   like txb.lon.opnamt
    field aaa2   like txb.lon.opnamt
    field aaa3   like txb.lon.opnamt
    field balans like txb.lon.opnamt
    field balans_kzt like txb.lon.opnamt
    field akkr like txb.lon.opnamt
    field garan like txb.lon.opnamt
    field crc    like txb.lon.crc
    field prem   like txb.lon.prem
    field dt1    like txb.lon.rdt
    field dt2    like txb.lon.rdt
    field dt3    like txb.lon.rdt
    field duedt  like txb.lon.rdt
    field rez    like txb.lonstat.prc
    field srez   like txb.lon.opnamt
    field zalog  like txb.lon.opnamt
    field sr as char
    field srok   as deci
    field tgt   as char                 /* объект кредитования */
    field num_dog like txb.loncon.lcnt  /* номер договора */
    field otrasl as char                 /* отрасль */
    field rate   as decimal        /* курс на день выдачи */
    field obes    as char                   /* вид обеспечения */
    field col_prolon as integer          /* кол-во пролонгаций */
    field sum_dolg as decimal           /* сумма просроченной задолженности */
    field sum_dox as decimal             /* сумма  */
    field ofc as char                    /* обслуживает менеджер */
    index main is primary crc desc balans desc grp.
