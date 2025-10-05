/**
 * Gets the user's current location using browser geolocation with IP fallback
 * @returns {Promise<{latitude: number, longitude: number, source: string}>}
 */
export const getCurrentLocation = async () => {
  // First try to get precise location
  try {
    if (navigator.geolocation) {
      const position = await new Promise((resolve, reject) => {
        navigator.geolocation.getCurrentPosition(resolve, reject, {
          enableHighAccuracy: true,
          timeout: 5000,
          maximumAge: 0
        });
      });

      const location = {
        latitude: position.coords.latitude,
        longitude: position.coords.longitude,
        source: 'browser_geolocation'
      };
      
      localStorage.setItem('userLocation', JSON.stringify(location));
      return location;
    }
  } catch (error) {
    console.warn('Error getting precise location:', error);
  }

  // If precise location fails, try IP-based location
  try {
    const response = await fetch('https://geolocation-db.com/json/');
    if (response.ok) {
      const data = await response.json();
      if (data.latitude && data.longitude) {
        const location = {
          latitude: parseFloat(data.latitude),
          longitude: parseFloat(data.longitude),
          source: 'ip_geolocation'
        };
        localStorage.setItem('userLocation', JSON.stringify(location));
        return location;
      }
    }
  } catch (error) {
    console.warn('Error getting IP-based location:', error);
  }

  // If all else fails, return null
  return null;
};

/**
 * Gets the stored user location from localStorage
 * @returns {{latitude: number, longitude: number, source: string} | null}
 */
export const getStoredLocation = () => {
  const stored = localStorage.getItem('userLocation');
  return stored ? JSON.parse(stored) : null;
};
