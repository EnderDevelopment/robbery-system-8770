Config = {}

-- Robbery settings
Config.RobberyCooldown = 3600 -- 1 hour cooldown in seconds
Config.RobberyDuration = 300 -- 5 minutes robbery duration in seconds
Config.RobberyReward = {min = 5000, max = 15000} -- Reward range
Config.RobberyPoliceAlert = 3 -- Number of police needed to stop robbery

-- Police settings
Config.PoliceJobName = 'police'
Config.PoliceAlertTime = 30 -- Time in seconds before police are alerted

-- Blip settings
Config.RobberyBlipSprite = 161
Config.RobberyBlipColor = 1
Config.RobberyBlipScale = 1.0
Config.RobberyBlipTime = 30 -- Time in seconds before blip disappears