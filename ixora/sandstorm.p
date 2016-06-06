/* sandstorm.p
 * MODULE
        Импорт списка лиц которые записаны в черный список в США
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
        6-8-5
 * AUTHOR
        04/03/2010 id00024
 * BASES
        BANK COMM
 * CHANGES
*/

def var er as char.
{xmlParser_id.i}
run parseFileXML ("sdn.xml", output er).

def buffer bst-node  for t-node.
def buffer bit-node  for t-node.
def buffer bit2-node for t-node.
def buffer bat-node  for t-node.
def buffer bat2-node for t-node.

def temp-table t-swblsdn like swblsdn.
def temp-table t-swblalt like swblalt.
def temp-table t-swbladd like swbladd.

for each t-node where t-node.nodeName = 'sdnEntry' no-lock:

	/* Заполнение таблицы t-swblsdn: Имя бандита */
	create t-swblsdn.
	for each bst-node where bst-node.nodeParentId = t-node.nodeId no-lock:
		case bst-node.nodeName:
		    when "uid"		then t-swblsdn.ent_num   = integer(bst-node.nodeValue).
		    when "lastName"	then t-swblsdn.SDN_Name  = bst-node.nodeValue.
		    when "firstName"	then t-swblsdn.Call_Sign = bst-node.nodeValue.
	            when "sdnType"	then t-swblsdn.SDN_Type  = bst-node.nodeValue.

	/* Заполнение таблицы t-swblalt: Алтерэго */
		    when "idList" then do:
				for each bit-node where bit-node.nodeParentId = bst-node.nodeId no-lock:
					if bit-node.nodeName = "id" then do:
						create t-swblalt.
						for each bit2-node where bit2-node.nodeParentId = bit-node.nodeId no-lock:
							case bit2-node.nodeName:
  							when "uid"		then t-swblalt.ent_num 		= t-swblsdn.ent_num.
							when "idType"		then t-swblalt.alt_type 	= bit2-node.nodeValue.
  							when "idNumber"		then t-swblalt.alt_num 		= bit2-node.nodeValue.
							when "idCountr"		then t-swblalt.alt_remarks 	= bit2-node.nodeValue.
							end case.
						end.
					end.
				end.
		    end.

	/* Заполнение таблицы t-swblalt: Кликухи */
		    when "aka" then do:
				for each bit-node where bit-node.nodeParentId = bst-node.nodeId no-lock:
					if bit-node.nodeName = "id" then do:
						create t-swblalt.
						for each bit2-node where bit2-node.nodeParentId = bit-node.nodeId no-lock:
							case bit2-node.nodeName:
  							when "uid"		then t-swblalt.ent_num 		= t-swblsdn.ent_num.
							when "type"		then t-swblalt.alt_type 	= bit2-node.nodeValue.
  							when "lastName"		then t-swblalt.alt_name		= bit2-node.nodeValue.
  							when "firstName"	then t-swblalt.alt_fname 	= bit2-node.nodeValue.
							when "category"		then t-swblalt.alt_category 	= bit2-node.nodeValue.
							end case.
						end.
					end.
				end.
		    end.

	/* Заполнение таблицы t-swbladd: Адреса проживания */
		    when "addressList" then do:
				for each bat-node where bat-node.nodeParentId = bst-node.nodeId no-lock:
					if bat-node.nodeName = "address" then do:
						create t-swbladd.
						for each bat2-node where bat2-node.nodeParentId = bat-node.nodeId no-lock:
							case bat2-node.nodeName:
 	 						when "uid"		then t-swbladd.ent_num  = t-swblsdn.ent_num.
							when "address1"		then t-swbladd.Address	= bat2-node.nodeValue.
							when "address2"		then t-swbladd.Address2	= bat2-node.nodeValue.
							when "address3"		then t-swbladd.Address3	= bat2-node.nodeValue.
							when "address4"		then t-swbladd.Address4	= bat2-node.nodeValue.
							when "city"		then t-swbladd.City 	= bat2-node.nodeValue.
							when "country"		then t-swbladd.Country 	= bat2-node.nodeValue.
							end case.
						end.
					end.
				end.
		    end.
		end case.
	end.	
end.

do transaction:
	for each t-swblsdn no-lock:
	create swblsdn. 
	buffer-copy t-swblsdn to swblsdn. 
	end.

	for each t-swblalt no-lock:
	create swblalt. 
	buffer-copy t-swblalt to swblalt. 
	end.

	for each t-swbladd no-lock:
	create swbladd. 
	buffer-copy t-swbladd to swbladd. 
	end.
end. /* transaction */
