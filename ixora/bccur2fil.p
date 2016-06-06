/* bccur2fil.p
 * MODULE
        Системные параметры
 * DESCRIPTION
        Копирование курсов валют средневзвешенных и истории на филиалы при изменениях в головном
 * RUN

 * CALLER
        bccur.p
 * SCRIPT

 * INHERIT

 * MENU
        9-1-2-2-1
 * AUTHOR
        21.11.2002 nadejda
 * CHANGES
        18.09.2003 nadejda - поставила копирование курса rate[1] в таблицу курсов НБ РК
        04/03/08 marinav - перевод цикла на r-branch, изменение адресов
        25.07.2011 aigul - recompile for curs2fil.i
*/

define shared var g-today  as date.

{curs2fil.i
&head = "crc"
&run = " run crc2nb (bank.crchis.who, bank.crchis.whn). "
}

procedure crc2nb.
  def input parameter v-ofc as char.
  def input parameter v-whn as date.

  def var v-ch as logical init false.

  find txb.crc where txb.crc.crc = p-crc no-lock no-error.
  find txb.ncrc where txb.ncrc.crc = txb.crc.crc exclusive-lock no-error.
  if avail txb.ncrc then do transaction:
    if txb.ncrc.rate[1] <> txb.crc.rate[1] then assign v-ch = true txb.ncrc.rate[1] = txb.crc.rate[1].
    if txb.ncrc.rate[9] <> txb.crc.rate[9] then assign v-ch = true txb.ncrc.rate[9] = txb.crc.rate[9].
    if txb.ncrc.decpnt  <> txb.crc.decpnt  then assign v-ch = true txb.ncrc.decpnt = txb.crc.decpnt.
    /* скопировать в историю */
    if v-ch then do:
      txb.ncrc.regdt = txb.crc.regdt.

      if g-today < today then do:
         find first txb.ncrchis where  txb.ncrchis.crc = txb.ncrc.crc and txb.ncrchis.rdt = g-today and txb.ncrchis.tim = 99999 no-error.
         if avail txb.ncrchis then delete txb.ncrchis.
      end.

      create txb.ncrchis.
      buffer-copy txb.ncrc to txb.ncrchis.

      txb.ncrchis.rdt = txb.ncrc.regdt.
      txb.ncrchis.who = v-ofc.
      txb.ncrchis.whn = v-whn.
      txb.ncrchis.tim = time.
      if g-today < today then txb.ncrchis.tim = 99999 .
    end.
  end.

end procedure.

