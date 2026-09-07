/**
 * hooks/useFeatureFlags.js
 *
 * Feature flag and plan tier checks.
 * Every feature in the app checks its flag here before rendering.
 * No feature renders unconditionally.
 *
 * Usage:
 *   const { isEnabled, isPlanOrAbove } = useFeatureFlags()
 *   if (!isEnabled('photos_enabled')) return null
 *
 * @returns {{
 *   isEnabled: (flagName: string) => boolean,
 *   isPlanOrAbove: (requiredTier: string) => boolean,
 *   planTier: string
 * }}
 */

import { useSettings } from './useSettings'
import { PLAN_TIERS } from '../constants/index'

/** Plan tier hierarchy — higher index = higher tier */
const TIER_ORDER = [
  PLAN_TIERS.SOLO,
  PLAN_TIERS.PRO,
  PLAN_TIERS.CREW,
  PLAN_TIERS.FRANCHISE,
]

export function useFeatureFlags() {
  const { settings } = useSettings()

  /**
   * Check if a feature flag is enabled in operator_settings.
   * Returns false if settings haven't loaded yet — safe default.
   * @param {string} flagName - must match a column name in operator_settings
   * @returns {boolean}
   */
  function isEnabled(flagName) {
    if (!settings) return false
    return settings[flagName] === true
  }

  /**
   * Check if the operator's plan tier meets or exceeds the required tier.
   * @param {string} requiredTier - one of PLAN_TIERS values
   * @returns {boolean}
   */
  function isPlanOrAbove(requiredTier) {
    if (!settings) return false
    const currentIndex = TIER_ORDER.indexOf(settings.plan_tier)
    const requiredIndex = TIER_ORDER.indexOf(requiredTier)
    return currentIndex >= requiredIndex
  }

  return {
    isEnabled,
    isPlanOrAbove,
    planTier: settings?.plan_tier ?? PLAN_TIERS.SOLO,
  }
}