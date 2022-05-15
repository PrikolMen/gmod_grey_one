local addon_name = "finaly_a_gray_one"

util.AddNetworkString( addon_name )

local damage = CreateConVar( "gray_one_damage", "1", FCVAR_ARCHIVE, "Enable gray one damage? (0 - 1)", 0, 1 ):GetBool()
cvars.AddChangeCallback("gray_one_damage", function(name, old, new)
	damage = tobool( new )
end, addon_name)

local chance = CreateConVar( "gray_one_chance", "2", FCVAR_ARCHIVE, "Chance of spawn the gray ball (0 - 100) in %.", 0, 100 ):GetInt()
cvars.AddChangeCallback("gray_one_chance", function( name, old, new )
	chance = tonumber( new )
end, addon_name)

local minimal_damage = CreateConVar( "gray_one_damage_min", "10", FCVAR_ARCHIVE, "Minimal damage when eating a gray ball (0 - 100).", 0, 90 ):GetFloat()
cvars.AddChangeCallback("gray_one_damage_min", function( name, old, new )
	minimal_damage = tonumber( new )
end, addon_name)

do

    local net_WriteVector = net.WriteVector
    local timer_Simple = timer.Simple
    local math_random = math.random
    local math_Rand = math.Rand
    local net_Start = net.Start
    local net_Send = net.Send
    local IsValid = IsValid
    local Vector = Vector

    local class_name = "sent_ball"
    hook.Add("OnEntityCreated", addon_name, function( ent )
        if (chance > 0) and (ent:GetClass() == class_name) then
            if (math_random( 1, 100 ) <= chance) then

                timer_Simple(0, function()
                    if IsValid( ent ) then
                        local gray = math_Rand( 0.25, 0.6 )
                        ent:SetBallColor( Vector( gray, gray, gray ) )
                    end
                end)

                function ent:Use( ply )
                    if not (damage) then return end
                    if IsValid( ply ) and ply:IsPlayer() then
                        net_Start( addon_name )
                            net_WriteVector( self:GetBallColor() )
                        net_Send( ply )

                        ply:TakeDamage( math_random( minimal_damage, ( ply:GetMaxHealth() - ply:Health() ) * 0.25 ), self )
                    end

                    self:Remove()
                end
            end
        end
    end)

end