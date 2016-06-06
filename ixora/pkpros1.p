/* pkpros1.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Анализ просроченных кредитов для управленческой
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
        29/07/2009 galina
 * BASES
        BANK TXB
 * CHANGES
        03/08/2009 madiyar - привязка к фактическим дням просрочки
        02/09/2009 galina - комиссия собирается по балансовым просрочкам
        04/02/2010 madiyar - перекомпиляция в связи с добавление поля в таблице londebt
        08/02/2010 madiyar - перекомпиляция
*/

def input parameter p-bank as char.
def input parameter bdat as date no-undo.

def var bilance as decimal no-undo.
def var v-com as decimal no-undo.
def var v-odpros as decimal no-undo.
def var v-prcpros as decimal no-undo.
def var v-pen as decimal no-undo.

def var v-days_od as integer no-undo.
def var v-days_prc as integer no-undo.
def var v-dayspros as integer no-undo.
def var v-sum as decimal no-undo.

/*выданные кредиты*/
def shared temp-table pkvyd
  field sum as decimal
  field amt as integer
  field bank as char.

/*кредитный потфель*/
def shared temp-table pkport
  field sum as decimal
  field bank as char.

/*просроченные долг*/
def shared temp-table pkpros
  field bank as char
  field sum_od as decimal
  field sum_prc as decimal
  field sum_pen as decimal
  field sum_com as decimal
  field sum_od1 as decimal
  field sum_prc1 as decimal
  field sum_pen1 as decimal
  field sum_com1 as decimal.


  create pkvyd.
  pkvyd.bank = p-bank.

  create pkpros.
  pkpros.bank = p-bank.

  create pkport.
  pkport.bank = p-bank.

  v-odpros = 0.
  v-prcpros = 0.
  v-days_od = 0.
  v-days_prc = 0.
  v-pen = 0.
  for each txb.lon no-lock:

    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if not avail txb.cif then next.
    if txb.lon.opnamt <= 0 then next.
    run lonbalcrc_txb('lon', txb.lon.lon, bdat, "1,7", no, txb.lon.crc, output bilance).
    if bilance <= 0 then next.

    find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt < bdat no-lock no-error.
    pkport.sum = pkport.sum + bilance * txb.crchis.rate[1].


    if txb.cif.type <> 'b' then do:
        v-com = 0.
        for each txb.bxcif where txb.bxcif.cif = txb.cif.cif and txb.bxcif.crc = txb.lon.crc no-lock:
           v-com = v-com + txb.bxcif.amount * txb.crchis.rate[1].
        end.

        run lonbalcrc_txb('lon',txb.lon.lon,bdat,"7",no,txb.lon.crc,output v-odpros).
        run lonbalcrc_txb('lon',txb.lon.lon,bdat,"9,4",no,txb.lon.crc,output v-prcpros).
        run lonbalcrc_txb('lon',txb.lon.lon,bdat,"16,5",no,1,output v-pen).
        run lndaysprf_txb(txb.lon.lon,bdat, no, output v-days_od, output v-days_prc).
        find first txb.londebt where txb.londebt.lon = txb.lon.lon no-lock no-error.

        if v-days_od > v-days_prc then v-dayspros = v-days_od.
        else  v-dayspros = v-days_prc.
        if v-dayspros > 0 and v-dayspros < 31 then do:

            pkpros.sum_od = pkpros.sum_od + v-odpros * txb.crchis.rate[1].
            pkpros.sum_prc = pkpros.sum_prc + v-prcpros * txb.crchis.rate[1].
            pkpros.sum_pen = pkpros.sum_pen + v-pen.
            if avail txb.londebt then pkpros.sum_com = pkpros.sum_com + v-com.
        end.
        if v-dayspros > 30 then do:
            pkpros.sum_od1 = pkpros.sum_od1 + v-odpros * txb.crchis.rate[1].
            pkpros.sum_prc1 = pkpros.sum_prc1 + v-prcpros * txb.crchis.rate[1].
            pkpros.sum_pen1 = pkpros.sum_pen1 + v-pen.
            if avail txb.londebt then pkpros.sum_com1 = pkpros.sum_com1 + v-com.
        end.
        if v-dayspros > 0 then do:
              run lonbalcrc_txb('lon',txb.lon.lon,bdat,"1,7",no,txb.lon.crc,output v-sum).
              pkvyd.sum = pkvyd.sum + v-sum * txb.crchis.rate[1].
              pkvyd.amt = pkvyd.amt + 1.
        end.
    end.
  end. /*for each txb.lon*/
