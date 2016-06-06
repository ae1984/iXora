define {1}  shared  var v-attn as char.
define {1}  shared  var v-doxras as char.
define {1}  shared var v-dep as char.
define {1}  shared var m1 as integer format 'z9'.
define {1}  shared var m2 as integer format 'z9'.
define {1}  shared var y1 as integer format '9999'.
define {1}  shared var v-date2 as date.
define {1}  shared var seltxb as int.
define {1}  shared var p-code as int.
define {1}  shared var depzl as char.

define  {1}   shared var v-pril as char .
define  {1}   shared var v-bank as char.
define  {1}   shared stream vcrpt.
define  {1}   shared var v-depname as char.

def {1} shared temp-table tottemp           /*А®ЄЮ ИҐ­­К© ў ЮЁ ­Б Б Ў-ФК temp ў Ю §ЮҐ§Ґ ¤ҐЇ ЮБ ¬Ґ­Б®ў*/
        field prz as integer
        field dep as char
        field depname as char
        field gl as char
        field des as char
        field sum as decimal.

def {1} shared temp-table bastjl     /*Б Ў«ЁФ  ЇЮ®ў®¤®Є Ї®  ¬®ЮБЁ§ ФЁЁ*/
      field gl like bank.jl.gl
      field gl1 like bank.jl.gl
      field jdt like bank.jl.jdt
      field ast like bank.jl.acc
      field dam like bank.jl.dam
      field cam like bank.jl.cam
      field dep as char
      field jh like bank.jl.jh .


def {1} shared temp-table temp2      /*Аў®¤­ О Б Ў«ЁФ  ¤®Е®¤®ў ®АБ БЄ®ў Ї® ўАҐ¬ АБ БЛО¬ ў Ю §ЮҐ§Ґ А®БЮ¤­ЁЄ , ¤ҐЇ ЮБ ¬Ґ­Б  Ї®¬ҐАОГ­®*/
        field tn   like  bank.ofc-tn.tn
        field tottn as integer
        field tottndep as integer
        field name like bank.ofc-tn.name
        field dep like bank.ofc-tn.dep
	field depname  like bank.ofc-tn.depname
	field post  as char
	field dnf as integer
	field rnn as char format 'x(9)'
	field mon as integer
	field pr30_4 as decimal
	field pr30_5 as decimal
	field pr30_6 as decimal
	field pr30_7 as decimal
	field pr30_8 as decimal
	field pr30_9 as decimal
	field pr30_10 as decimal
	field pr30_11 as decimal
	field pr30_12 as decimal
	field pr30_13 as decimal
	field pr30_14 as decimal
	field pr30_15 as decimal
	field pr30_16 as decimal
	field pr30_17 as decimal
	field pr30_18 as decimal
	field pr30_19 as decimal
	field pr30_20 as decimal
	field pr30_21 as decimal
	field pr30_22 as decimal
	field pr30_23 as decimal
	field pr30_24 as decimal
	field pr30_25 as decimal
	field pr30_26 as decimal
	field pr30_27 as decimal
	field pr30_28 as decimal
	field pr30_29 as decimal
	field pr30_30 as decimal
	field pr30_31 as decimal
	field pr30_32 as decimal
	field pr30_33 as decimal
	field pr30_34 as decimal
	field pr30_35 as decimal
	field pr30_36 as decimal
	field pr31_4 as decimal
	field pr31_5 as decimal
	field pr31_6 as decimal
	field pr31_7 as decimal
	field pr31_8 as decimal
	field pr31_9 as decimal
	field pr31_10 as decimal
	field pr31_11 as decimal
	field pr31_12 as decimal
	field pr31_13 as decimal
	field pr31_14 as decimal
	field pr31_15 as decimal
	field pr32_4 as decimal
	field pr32_5 as decimal
	field pr32_6 as decimal
	field pr32_7 as decimal
	field pr32_8 as decimal
	field pr32_9 as decimal
	field pr32_10 as decimal
	field pr32_11 as decimal
	field pr32_12 as decimal
	field pr32_13 as decimal
	field pr32_14 as decimal
	field pr32_15 as decimal
	field pr32_16 as decimal
	field pr32_17 as decimal
	field pr32_18 as decimal
	field pr32_19 as decimal
	field pr32_20 as decimal
	field pr32_21 as decimal
	field pr32_22 as decimal
	field pr32_23 as decimal
	field pr32_24 as decimal
	field pr32_25 as decimal
	field pr33_4 as decimal
	field pr33_5 as decimal
	field pr33_6 as decimal
	field pr33_7 as decimal
	field pr33_8 as decimal
	field pr33_9 as decimal
	field pr33_10 as decimal
	field pr33_11 as decimal
	field pr33_12 as decimal
	field pr33_13 as decimal
	field pr33_14 as decimal
	field pr33_15 as decimal
	field pr33_16 as decimal
	field pr34_4 as decimal
	field pr34_5 as decimal
	field pr34_6 as decimal
	field pr34_7 as decimal
	field pr34_8 as decimal
	field pr34_9 as decimal
	field pr34_10 as decimal
	field pr34_11 as decimal
        index dep is primary   dep .

def {1} shared temp-table temp      /*Аў®¤­ О Б Ў«ЁФ  Ю АЕ®¤®ў ®АБ БЄ®ў Ї® ўАҐ¬ АБ БЛО¬ ў Ю §ЮҐ§Ґ А®БЮ¤­ЁЄ , ¤ҐЇ ЮБ ¬Ґ­Б  Ї®¬ҐАОГ­®*/
        field tn   like  bank.ofc-tn.tn
        field tottn as integer
        field tottndep as integer
        field name like bank.ofc-tn.name
        field dep like bank.ofc-tn.dep
	field depname  like bank.ofc-tn.depname
	field post  as char
	field dnf as integer
	field rnn as char format 'x(9)'
	field mon as integer
	field oklad as decimal
	field otpusk as decimal
	field nadb as decimal
	field prem as decimal
	field posob as decimal
	field hlp as decimal
	field nalog as decimal
	field otch as decimal
	field schi as integer
	field pr3_7 as decimal
	field pr3_8 as decimal
	field pr3_9 as decimal
	field pr3_10 as decimal
	field pr3_11 as decimal
	field pr3_12 as decimal
	field pr3_13 as decimal
	field pr3_14 as decimal
	field pr4_7 as decimal
	field pr4_8 as decimal
	field pr4_9 as decimal
	field pr4_10 as decimal
	field pr4_11 as decimal
	field pr4_12 as decimal
	field pr4_14 as decimal
	field pr4_15 as decimal
	field pr4_16 as decimal
	field pr5_9 as decimal
	field pr5_10 as decimal
	field pr5_11 as decimal
	field pr5_13 as decimal
	field pr5_14 as decimal
	field pr5_15 as decimal
	field pr5_16 as decimal
	field pr5_17 as decimal
	field pr5_18 as decimal
	field pr5_19 as decimal
	field pr5_20 as decimal
	field pr5_21 as decimal
	field pr5_22 as decimal
	field pr6_7 as decimal
	field pr6_8 as decimal
	field pr7_6 as decimal
	field pr7_7 as decimal
	field pr7_8 as decimal
	field pr7_9 as decimal
	field pr8_4 as decimal
	field pr8_5 as decimal
	field pr8_6 as decimal
	field pr8_7 as decimal
	field pr8_8 as decimal
	field pr8_9 as decimal
	field pr8_10 as decimal
	field pr8_11 as decimal
	field pr9_4 as decimal
	field pr9_5 as decimal
	field pr9_6 as decimal
	field pr9_7 as decimal
	field pr10_4 as decimal
	field pr10_5 as decimal
	field pr10_6 as decimal
	field pr10_7 as decimal
	field pr10_8 as decimal
	field pr10_9 as decimal
	field pr10_10 as decimal
	field pr11_4 as decimal
	field pr11_5 as decimal
	field pr11_6 as decimal
	field pr11_7 as decimal
	field pr11_8 as decimal
	field pr11_9 as decimal
	field pr11_10 as decimal
	field pr11_11 as decimal
	field pr11_12 as decimal
	field pr11_13 as decimal
	field pr11_14 as decimal
	field pr11_15 as decimal
	field pr11_16 as decimal
	field pr11_17 as decimal
	field pr11_18 as decimal
	field pr11_19 as decimal
	field pr11_20 as decimal
	field pr11_21 as decimal
	field pr11_22 as decimal
	field pr11_23 as decimal
	field pr11_24 as decimal
	field pr11_25 as decimal
	field pr11_26 as decimal
	field pr11_27 as decimal
	field pr12_4 as decimal
	field pr12_5 as decimal
	field pr12_6 as decimal
	field pr12_7 as decimal
	field pr12_8 as decimal
	field pr12_9 as decimal
	field pr12_10 as decimal
	field pr13_4 as decimal
	field pr13_5 as decimal
	field pr13_6 as decimal
	field pr13_7 as decimal
	field pr13_8 as decimal
	field pr13_9 as decimal
	field pr13_10 as decimal
	field pr13_11 as decimal
	field pr13_12 as decimal
	field pr13_13 as decimal
	field pr13_14 as decimal
	field pr13_15 as decimal
	field pr13_16 as decimal
	field pr14_4 as decimal
	field pr14_5 as decimal
	field pr14_6 as decimal
	field pr14_7 as decimal
	field pr14_8 as decimal
	field pr15_4 as decimal
	field pr15_5 as decimal
	field pr15_6 as decimal
	field pr15_7 as decimal
	field pr15_8 as decimal
	field pr15_9 as decimal
        index dep is primary   dep .

def {1} shared temp-table temp1      /*Аў®¤­ О Б Ў«ЁФ  Ю АЕ®¤®ў ®АБ БЄ®ў Ї® ўАҐ¬ АБ БЛО¬ ў Ю §ЮҐ§Ґ А®БЮ¤­ЁЄ , ¤ҐЇ ЮБ ¬Ґ­Б  Ї®¬ҐАОГ­®*/
        field tn   like  bank.ofc-tn.tn
        field tottn as integer
        field tottndep as integer
        field name like bank.ofc-tn.name
        field dep like bank.ofc-tn.dep
	field depname  like bank.ofc-tn.depname
	field post  as char
	field dnf as integer
	field rnn as char format 'x(9)'
	field mon as integer
	field pr16_4 as decimal
	field pr16_5 as decimal
	field pr16_6 as decimal
	field pr16_7 as decimal
	field pr16_8 as decimal
	field pr16_9 as decimal
	field pr16_10 as decimal
	field pr16_11 as decimal
	field pr16_12 as decimal
	field pr17_4 as decimal
	field pr17_5 as decimal
	field pr17_6 as decimal
	field pr17_7 as decimal
	field pr17_8 as decimal
	field pr17_9 as decimal
	field pr17_10 as decimal
	field pr17_11 as decimal
	field pr18_4 as decimal
	field pr18_5 as decimal
	field pr18_6 as decimal
	field pr19_4 as decimal
	field pr19_5 as decimal
	field pr19_6 as decimal
	field pr19_7 as decimal
	field pr20_4 as decimal
	field pr20_5 as decimal
	field pr20_6 as decimal
	field pr20_7 as decimal
	field pr20_8 as decimal
	field pr20_9 as decimal
	field pr20_10 as decimal
	field pr20_11 as decimal
         index dep is primary   dep .

def {1} shared temp-table t-cods     /*Б Ў«ЁФ  Є®¤®ў Ю АЕ®¤®ў-¤®Е®¤®ў*/
	field code like bank.cods.code   
	field dep  like bank.cods.dep 
	field crc  like bank.crc.code
	field gl   like bank.jl.gl
	field dam  like bank.jl.dam
	field cam  like bank.jl.cam
	field acc  like bank.jl.acc
	field jdt  like bank.jl.jdt
	field jh   like bank.jl.jh
	field who  like bank.jl.who 
	field rem  as char 
	field ls  like bank.jl.acc
	field rnn as char format 'x(9)'
         index jh jh 
         index glcods is primary gl code .
