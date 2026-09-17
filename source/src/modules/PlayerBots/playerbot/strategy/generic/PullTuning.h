#pragma once

namespace ai
{
    // Pull tuning, deliberately NOT in PlayerbotAIConfig.h.
    //
    // That header sits inside the precompiled header: botpch.h includes
    // strategy/Action.h, which includes PlayerbotAIConfig.h. So adding a single
    // float there invalidates the PCH and recompiles ALL 461 translation units
    // in the module. Measured 2026-09-07: ~220 s for a config knob against
    // ~17 s for a change confined to one .cpp. Six pull knobs went in there
    // over the course of building this, and every one of them cost a full
    // rebuild.
    //
    // Here they cost the three files that actually read them. Changing a value
    // is a ~20 s build rather than a conf edit plus a restart, which is the same
    // order of time and does not need the value to exist in two places.
    //
    // If any of these ever genuinely needs to be tuned without a build, move
    // that ONE value to PlayerbotAIConfig and pay for it knowingly.
    namespace PullTuning
    {
        // How close to the anchor counts as home. Read by both the Returning
        // state and the walk-back action - they must agree, or the pull can
        // never end.
        const float AnchorTolerance = 1.0f;

        // Inside this, a ranged opener is pointless: guns and bows have a real
        // 5 yd minimum and CheckCast refuses below it. The margin above that
        // floor keeps a target drifting closer from spoiling a shot in flight.
        const float MinRange = 8.0f;

        // Seconds to stand on the anchor letting them come. A ceiling, not a
        // duration - melee contact ends it early.
        const float HoldSeconds = 5.0f;

        // How often the approach re-checks its distance while closing, in ms.
        // ChaseTo would otherwise wait out the whole travel time before looking
        // again, which is too coarse to notice arriving.
        const uint32 PollInterval = 250;
    }
}
