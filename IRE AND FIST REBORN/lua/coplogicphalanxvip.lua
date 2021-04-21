-- Make sure the assault actually ends if Winters dies
function CopLogicPhalanxVip.death_clbk(data, damage_info)
	managers.groupai:state():unregister_phalanx_vip()
end
