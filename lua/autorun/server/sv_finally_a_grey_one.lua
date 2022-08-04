local addon_name = "finaly_a_grey_one"
local achievements = {}

util.AddNetworkString( addon_name )

local damage = CreateConVar( "grey_one_damage", "1", FCVAR_ARCHIVE, "Enable grey one damage? (0 - 1)", 0, 1 ):GetBool()
cvars.AddChangeCallback("grey_one_damage", function(name, old, new)
	damage = tobool( new )
end, addon_name)

local chance = CreateConVar( "grey_one_chance", "2", FCVAR_ARCHIVE, "Chance of spawn the grey ball (0 - 100) in %.", 0, 100 ):GetInt()
cvars.AddChangeCallback("grey_one_chance", function( name, old, new )
	chance = tonumber( new )
end, addon_name)

local minimal_damage = CreateConVar( "grey_one_damage_min", "10", FCVAR_ARCHIVE, "Minimal damage when eating a grey ball (0 - 100).", 0, 90 ):GetFloat()
cvars.AddChangeCallback("grey_one_damage_min", function( name, old, new )
	minimal_damage = tonumber( new )
end, addon_name)

do

    local timer_Simple = timer.Simple
    local math_random = math.random
    local math_Rand = math.Rand
    local IsValid = IsValid
    local Vector = Vector

    hook.Add("PlayerSpawnedSENT", addon_name, function( ply, ent )
        if (chance > 0) and (ent:GetClass() == "sent_ball") then
            if IsValid( ply ) then
                if (math_random( 1, 100 ) <= chance) then

                    if (achievements[ ply:SteamID64() ] == nil) then
                        ply:ConCommand( "grey_one_achievement" )
                        achievements[ ply:SteamID64() ] = true

                        net.Start( addon_name )
                            net.WriteBool( false )
                            net.WriteEntity( ply )
                        net.Broadcast()
                    end

                    timer_Simple(0, function()
                        if IsValid( ent ) then
                            local grey = math_Rand( 0.25, 0.6 )
                            ent:SetBallColor( Vector( grey, grey, grey ) )
                        end
                    end)

                    function ent:Use( activator )
                        if not (damage) then return end
                        if IsValid( activator ) and activator:IsPlayer() then
                            net.Start( addon_name )
                                net.WriteBool( true )
                                net.WriteVector( self:GetBallColor() )
                            net.Send( activator )

                            activator:TakeDamage( math_random( minimal_damage, ( activator:GetMaxHealth() - activator:Health() ) * 0.25 ), self )
                        end

                        self:Remove()
                    end
                end
            end
        end
    end)

end