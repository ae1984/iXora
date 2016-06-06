/* mqownr1.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Сихронизация платежей для интернет-банкинга.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        TXB COMM
 * AUTHOR
        09/10/11 id00004
 * CHANGES
        06.05.2011 id00004 исправил ошибку при если нет записи в таблице que

*/



  def shared temp-table t_in   /*   */
  field id as char format 'x(60)'
  field sts  as char.

  def shared temp-table t_out  /*        */
  field id as char format 'x(60)'
  field realstatus  as char
  field descr  as char
  field tim  as integer
  field datesend  as date
  field typepeyment  as char.


  def var inder as integer . 
  def var m_status as char .
  def var m_desc as char .
  def var m_tim as integer .
  def var m_datesend as date .
  def var m_typepeyment as char .


  inder = 0.
  find last txb.sysc where txb.sysc.sysc = 'ourbnk' no-lock no-error.


  for each  t_in no-lock:
      inder = 0.
      if t_in.sts = '1' then next.
      if t_in.sts = '2' then next.
      if t_in.sts = '3' then next.
      if t_in.sts = '7' then next.
      find last netbank  where  netbank.id = t_in.id and netbank.txb = txb.sysc.chval no-lock no-error.
      if avail netbank then do:

            inder = 0.   
            m_status = "".
            m_desc = "".
            m_tim = 0.
            m_datesend = ?.
            m_typepeyment = "".

            find last txb.remtrz where txb.remtrz.remtrz = netbank.rmz no-lock no-error.
            if not avail txb.remtrz then next.
            find last txb.que where txb.que.remtrz = txb.remtrz.remtrz no-lock no-error.
            if not avail txb.que then next.
            if (avail txb.remtrz) and (txb.remtrz.fcrc = 1) then  m_typepeyment = "PAYMENT".
            if (avail txb.remtrz) and (txb.remtrz.fcrc <> 1) then  m_typepeyment = "CURRENCY_PAYMENT".
            if (avail txb.remtrz) and (txb.remtrz.jh1 <> ?) then do:
               find last txb.jh where txb.jh.jh = txb.remtrz.jh1 no-lock no-error.
               if avail txb.jh  then do:
                  m_datesend = jh.jdt.
                  m_tim = jh.tim.
               end.
            end.


            if t_in.sts = '4' then do:
               if (not avail txb.remtrz) or (avail txb.remtrz and txb.remtrz.jh1 = ? and txb.que.pid = "ARC") then do:
                  inder = 1. 
                  m_status = "6".  /* статус удален*/
                  m_desc = "Отвергнут".
               end.
               if (avail txb.remtrz and txb.remtrz.jh1 <> ? ) then do:
                  inder = 1. m_status = "5".  /*статус исполнен*/
                  m_desc = "Исполнен".
               end.
            end.


            if t_in.sts = '5' then do:
               if (not avail txb.remtrz) or (avail txb.remtrz and txb.remtrz.jh1 = ? and txb.que.pid = "ARC")  then do:
                  inder = 1. 
                  m_status = "6". /*статус удален*/
                  m_desc = "Отвергнут".
               end.
            end.

            if t_in.sts = '6' then do:
               if (avail txb.remtrz and txb.remtrz.jh1 <> ? ) then do:
                  inder = 1. 
                  m_status = "5".  /*статус исполнен*/
                  m_desc = "Исполнен".
               end.
            end.




            if inder = 1 then do:
               create t_out.
                      t_out.id = t_in.id.
                      t_out.realstatus = m_status.
                      t_out.descr = m_desc.
                      t_out.tim = m_tim. 
                      t_out.datesend = m_datesend.
                      t_out.typepeyment = m_typepeyment.

            end.


      end.   /*if avail netbank*/
  end.


