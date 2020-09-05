state("HeaveHo", "steam-windows-5468403")
{
    // levelSelector : "UnityPlayer.dll", 0x01546BD8, 0x48, 0x68, 0xB0, 0x138;
    string128 levelName : "UnityPlayer.dll", 0x01546BD8, 0x48, 0x68, 0xB0, 0x138, 0x58, 0x10, 0x14;
    string128 worldName : "UnityPlayer.dll", 0x01546BD8, 0x48, 0x68, 0xB0, 0x138, 0x60, 0x18, 0x14;

    // gameManager : "UnityPlayer.dll", 0x01499CC0, 0x80, 0x28, 0x8, 0x8, 0x10, 0x28;
    int timesLen : "UnityPlayer.dll", 0x01499CC0, 0x80, 0x28, 0x8, 0x8, 0x10, 0x28, 0xB8, 0x10, 0x10, 0x18;
    float level1Time : "UnityPlayer.dll", 0x01499CC0, 0x80, 0x28, 0x8, 0x8, 0x10, 0x28, 0xB8, 0x10, 0x10, 0x10, 0x20;
    float level2Time : "UnityPlayer.dll", 0x01499CC0, 0x80, 0x28, 0x8, 0x8, 0x10, 0x28, 0xB8, 0x10, 0x10, 0x10, 0x24;
    float level3Time : "UnityPlayer.dll", 0x01499CC0, 0x80, 0x28, 0x8, 0x8, 0x10, 0x28, 0xB8, 0x10, 0x10, 0x10, 0x28;
    float level4Time : "UnityPlayer.dll", 0x01499CC0, 0x80, 0x28, 0x8, 0x8, 0x10, 0x28, 0xB8, 0x10, 0x10, 0x10, 0x2C;
    float level5Time : "UnityPlayer.dll", 0x01499CC0, 0x80, 0x28, 0x8, 0x8, 0x10, 0x28, 0xB8, 0x10, 0x10, 0x10, 0x30;
    bool isInMainMenu : "UnityPlayer.dll", 0x01499CC0, 0x80, 0x28, 0x8, 0x8, 0x10, 0x28, 0x121;

    // levelManager : "UnityPlayer.dll", 0x01499CC0, 0x80, 0x28, 0x8, 0x8, 0x10, 0x28, 0xE0;
    bool isLevelOver : "UnityPlayer.dll", 0x01499CC0, 0x80, 0x28, 0x8, 0x8, 0x10, 0x28, 0xE0, 0x86;

    /*
    // levelRules : "UnityPlayer.dll", 0x01499CC0, 0x80, 0x28, 0x8, 0x8, 0x10, 0x28, 0xE0, 0x20;
    float timeStarted : "UnityPlayer.dll", 0x01499CC0, 0x80, 0x28, 0x8, 0x8, 0x10, 0x28, 0xE0, 0x20, 0x30;
    */
}

startup
{
    vars.levelIdx = -1;
    vars.totalTime = 0.0f;
    vars.watch = new System.Diagnostics.Stopwatch();
}

shutdown
{ }

init
{
    timer.IsGameTimePaused = false;
}

exit
{
    timer.IsGameTimePaused = true;
}

update
{
    current.times = new float[] { current.level1Time, current.level2Time, current.level3Time, current.level4Time, current.level5Time };

    if (current.timesLen == old.timesLen + 1)
    {
        // Triggers at the end of a level when the time sign pops out
        timer.IsGameTimePaused = true;
        vars.watch.Stop();
    }

    if (current.levelName != old.levelName)
    {
        if (vars.levelIdx == 0 && old.worldName != current.worldName)
        {
            print("World " + current.worldName + " started.");
        }

        if (current.timesLen > 0)
        {
            print("Level changed from " + old.levelName + " to " + current.levelName);
            vars.totalTime += current.times[vars.levelIdx];
            ++vars.levelIdx;
        }

        vars.watch.Stop();
        vars.watch.Reset();
        if (current.levelName != null && !current.levelName.Contains("Ceremony"))
        {
            // If not at the world final scene, restart for the next level
            vars.watch.Start();
        }

        timer.IsGameTimePaused = !vars.watch.IsRunning;
    }

    return true;
}

start
{
    if ((current.levelName != old.levelName || (old.isInMainMenu && !current.isInMainMenu)) && current.levelName == "Tuto1")
    {
        print("Start!");
        vars.levelIdx = 0;
        vars.totalTime = 0.0f;
        vars.watch.Restart();
        return true;
    }
    return false;
}

reset
{
    /*if (!old.isInMainMenu && current.isInMainMenu)
    {
        print("Reset! (main menu)");
        return true;
    }*/
    if (current.levelName != old.levelName && current.levelName == "Tuto1")
    {
        print("Reset! (start at Tuto1)");
        return true;
    }

    return false;
}

split
{
    if ((vars.levelIdx == 4 && current.worldName == "Tuto") || vars.levelIdx == 5)
    {
        print("Split! World " + current.worldName + " completed.");
        vars.levelIdx = 0;
        timer.IsGameTimePaused = true;
        return true;
    }
    return false;
}

gameTime
{
    TimeSpan total = TimeSpan.FromSeconds(vars.totalTime);
    return total + vars.watch.Elapsed;
}
