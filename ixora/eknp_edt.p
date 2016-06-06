/* eknp_edt.p
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

/*
  sadgasdg
*/

def var s_gl as char format 'x(6)'.
def var r_gl as char format 'x(6)'.
def var knp as char format 'x(3)'.
define buffer btrxc for trxcods.
define buffer bjl for jl.
def var i as integer init 0.
define button bt1 label "Редактировать".
def button bt2 label "Выход".

define temp-table m_table
  field  s_mfoacc as char format 'x(9)'
  field  r_mfoacc as char format 'x(9)'
  field  s_gl as char format 'x(9)' 
  field  r_gl as char format 'x(9)' 
  field  s_locat as char format 'x(1)' label ""  
  field  s_secek like s_locat
  field  r_locat like s_locat
  field  r_secek like s_locat 
  field  spnpl   like trxcods.code format 'x(3)'  label "КНП"
  field  amt     like jl.dam
  field  crc     like crc.crc
  field  jh      like jl.jh
  field  slog    as integer init 0
  field  rlog    as integer init 0
  field  p_type  as char
  field  r_id    as rowid.

define temp-table m_table1
  field  s_gl as char format 'x(9)' 
  field  r_gl as char format 'x(9)' 
  field  s_locat as char format 'x(1)' label ""  
  field  s_secek like m_table.s_locat
  field  r_locat like m_table.s_locat
  field  r_secek like m_table.s_locat 
  field  spnpl   like trxcods.code format 'x(3)'  label "КНП"
  field  amt     like jl.dam
  field  crc     like crc.crc
  field  jh      like jl.jh
  field  p_type  as char
  field  r_id    as char.


define var bdate as date.
define var edate as date.

def query q1 for m_table1.
def browse b1 query q1 
    display m_table1.s_gl 
            m_table1.r_gl 
            m_table1.s_locat 
            m_table1.s_secek 
            m_table1.r_locat 
            m_table1.r_secek 
            m_table1.spnpl
            m_table1.amt 
          enable             
            m_table1.s_locat 
            m_table1.s_secek 
            m_table1.r_locat 
            m_table1.r_secek 
            m_table1.spnpl
/*     validate((m_table1.s_locat = '1' or m_table1.s_locat  = '2') and (m_table1.r_locat = '1' or m_table1.r_locat  = '2'), 'Резидент 1/ Нерезидент 2')*/
 with 10 down width 78.

define frame f1
       b1 skip
       bt2
       bt1.

update 'Введите период с ' bdate ' по ' edate skip with no-labels.
update "Введите счет ДТ:" s_gl "КТ:" r_gl /*"КНП:" knp*/ with no-labels.
/*
bdate = 10/02/02.
edate = 10/31/02.

s_gl = '255110'.
r_gl = '287044'.*/

for each jl where jl.jdt >= bdate and jl.jdt <= edate and jl.ln modulo 2 <> 0 and string(jl.gl) = s_gl no-lock by jl.jh by jl.ln: 
    find first bjl where bjl.jh = jl.jh and bjl.ln = jl.ln + 1 no-lock no-error.
    if avail bjl and string(bjl.gl) = r_gl then 
       do:
          find first trxcods where trxcods.trxh = jl.jh and trxcods.trxln = jl.ln and (trxcods.codfr = 'locat') no-lock no-error.
          if avail trxcods 
             then 
                 do:
                    create m_table.
                    m_table.crc = jl.crc.
                    m_table.jh = jl.jh.   
                    m_table.s_gl = string(jl.gl).
                    m_table.r_gl = string(bjl.gl).                  
                    m_table.slog = jl.ln.
                    m_table.rlog = bjl.ln.
                    m_table.amt = jl.dam.
                    m_table.s_locat = trxcods.code. 
                    m_table.p_type = 'trx'.
                    m_table.r_id = rowid(trxcods).
                    find first btrxc where btrxc.trxh = jl.jh and btrxc.trxln = jl.ln and (btrxc.codfr = 'secek') no-lock no-error.
                    if avail btrxc then m_table.s_secek = btrxc.code.
                    find first btrxc where btrxc.trxh = jl.jh and btrxc.trxln = jl.ln and (btrxc.codfr = 'spnpl') no-lock no-error.        
                    if avail btrxc then m_table.spnpl = btrxc.code.
                    find first btrxc where btrxc.trxh = bjl.jh and btrxc.trxln = bjl.ln and (btrxc.codfr = 'locat') no-lock no-error.
                    if avail btrxc then m_table.r_locat = btrxc.code.
                    find first btrxc where btrxc.trxh = bjl.jh and btrxc.trxln = bjl.ln and (btrxc.codfr = 'secek') no-lock no-error.        
                    if avail btrxc then m_table.r_secek = btrxc.code.
                 end.                          
             else
                 do:
                    if (jl.gl = 255110 or jl.gl = 220310) and (bjl.gl = 186034 or bjl.gl = 187053 or 
                       bjl.gl = 220310 or bjl.gl = 221120 or bjl.gl = 287044 or bjl.gl = 255120) and jl.crc <> 1 
                       then 
                         do: 
                            create m_table.
                            m_table.crc = jl.crc.
                            m_table.jh = jl.jh.   
                            m_table.s_gl = string(jl.gl).
                            m_table.r_gl = string(bjl.gl).                  
                            m_table.slog = jl.ln.
                            m_table.rlog = bjl.ln.
                            m_table.amt = jl.dam.
                            m_table.p_type = 'sub'.
                            find sub-cod where sub-cod.acc = substr(jl.rem[1],1,10) and sub-cod.sub = 'rmz' and sub-cod.d-cod = 'eknp' no-lock no-error.
                            if avail sub-cod then 
                               do:
                                  m_table.s_locat = substr(sub-cod.rcod,1,1). 
                                  m_table.s_secek = substr(sub-cod.rcod,2,1).
                                  m_table.spnpl = substr(sub-cod.rcod,7,3).
                                  m_table.r_locat = substr(sub-cod.rcod,4,1).
                                  m_table.r_secek = substr(sub-cod.rcod,5,1).
                                  m_table.r_id = rowid(sub-cod).
                               end.
                            else
                              do:
                                  create sub-cod.
                                  sub-cod.sub = 'rmz'.
				  sub-cod.acc = substr(jl.rem[1],1,10).
				  sub-cod.d-cod = 'eknp'.
				  sub-cod.ccode = 'msc'.
                                  m_table.r_id = rowid(sub-cod).
                                  output to 'log.txt' append.
                                  display 'createing empty subcode'. 
  				  display sub-cod with no-labels.
			          output close.

                              end.
                         end. 
                 end.
       end.
 end.

for each m_table break by m_table.s_gl by m_table.r_gl by 
                          m_table.s_locat by m_table.s_secek by 
                          m_table.r_locat by m_table.r_secek by 
                          m_table.spnpl by m_table.crc:
    ACCUMULATE m_table.amt (SUB-TOTAL SUB-COUNT by m_table.s_gl by m_table.r_gl by 
                                                   m_table.s_locat by m_table.s_secek by 
                                                   m_table.r_locat by m_table.r_secek by 
                                                   m_table.spnpl by m_table.crc).
    if first-of (m_table.crc) then
       do:
           create m_table1.
/*           i = 0.  */
           m_table1.r_id = string(m_table.r_id).
           m_table1.s_locat = m_table.s_locat.
           m_table1.s_secek = m_table.s_secek.
           m_table1.r_locat = m_table.r_locat.
           m_table1.r_secek = m_table.r_secek.
           m_table1.r_gl = m_table.r_gl.
           m_table1.s_gl = m_table.s_gl.
           m_table1.spnpl   = m_table.spnpl.
           m_table1.p_type = m_table.p_type.
       end.  
     else 
       do: 
          m_table1.r_id = m_table1.r_id + ';' + string(m_table.r_id).
       end.
/*    i = i + 1.*/
/*    entry (i,m_table1.r_id," ") = string(m_table.r_id).*/

    if last-of (m_table.crc) 
       then
         do:
            m_table1.amt = ACCUM SUB-TOTAL by m_table.crc m_table.amt.    
/*            display m_table except m_table.slog m_table.rlog m_table.jh m_table.amt m_table.s_mfoacc m_table.r_mfoacc m_table.r_id. 
            display ACCUM SUB-TOTAL by m_table.crc m_table.amt format "zzz,zzz,zzz,zzz.99" label "Сумма".
            display ACCUM SUB-COUNT by m_table.crc m_table.amt label "Кол-во".            */
         end.
/*    displ m_table except m_table.slog m_table.rlog m_table.jh. */
end.

/*
for each m_table1:
displ m_table1.r_id format 'x(70)'.
end.*/

on choose of bt1
do:
   message "Update " /*m_table1.p_type*/ view-as alert-box.
   if m_table1.p_type = 'trx' then 
      do: 
        do i = 1 to NUM-ENTRIES(m_table1.r_id,';') by 1 :
           find trxcods where rowid(trxcods) =TO-ROWID(entry(i,m_table1.r_id,';')).
           if avail trxcods then 
              do:
/*                 message 'ne mozhet byt!!!!!' view-as alert-box.*/
                 for each btrxc where btrxc.trxh = trxcods.trxh and btrxc.trxln = trxcods.trxln:
                     if btrxc.codfr = 'locat' then btrxc.code = m_table1.s_locat.
                     if btrxc.codfr = 'secek' then btrxc.code = m_table1.s_secek.
                     if btrxc.codfr = 'spnpl' then btrxc.code = m_table1.spnpl.
                 end.
                 for each btrxc where btrxc.trxh = trxcods.trxh and btrxc.trxln = trxcods.trxln + 1:
                     if btrxc.codfr = 'locat' then btrxc.code = m_table1.r_locat.
                     if btrxc.codfr = 'secek' then btrxc.code = m_table1.r_secek.
                     if btrxc.codfr = 'spnpl' then btrxc.code = m_table1.spnpl.
                 end.
              end.  
           else
             do:
/*                message 'pervyi variant !!! a vot tut nado 4ego to vstavit!!!' view-as alert-box.*/
             end.

        end.
      end.
   if m_table1.p_type = 'sub' then 
      do: 
        output to 'log.txt' append.
        display m_table1 with no-labels.
        output close.
        do i = 1 to NUM-ENTRIES(m_table1.r_id,';') by 1 :
/*           message 'proverka!!!!!' view-as alert-box.*/
           find sub-cod where rowid(sub-cod) =TO-ROWID(entry(i,m_table1.r_id,';')).
           if avail sub-cod then 
              do: 
                 output to 'log.txt' append.
                 display sub-cod with no-labels.
                 output close.

/*                 message 'ogogo!!!!!' view-as alert-box.*/
                 if sub-cod.ccode = 'msc' 
                     then sub-cod.rcod = ',,'.
                 entry(1,sub-cod.rcod,',') = m_table1.s_locat + m_table1.s_secek. 
                 entry(2,sub-cod.rcod,',') = m_table1.r_locat + m_table1.r_secek.
                 entry(3,sub-cod.rcod,',') = m_table1.spnpl.
              end.
           else
             do:
/*                message 'a vot tut nado 4ego to vstavit!!!' view-as alert-box.*/
             end.
        end.
      end.
end.

on choose of bt2
do:
   hide all.
end.

open query q1 for each m_table1.

enable all with frame f1.

wait-for choose of bt2 or window-close of current-window.
