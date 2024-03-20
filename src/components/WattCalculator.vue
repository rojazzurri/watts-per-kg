<template>
  <div>
    <h2>Cycling Performance Calculator</h2>
    <form @submit.prevent="calculate">
      <!-- Form inputs -->
      <div>Distance: <input v-model.number="distance" placeholder="Distance du CLM (km)" /></div>
      <div>PR: <input v-model="timeRecord" placeholder="Temps record (min)" /></div>
      <div>avg watts<input v-model.number="averageWatts" placeholder="Watt utilisé moyen" /></div>
      <div>poids:<input v-model.number="cyclistWeight" placeholder="Poid du cycliste (kg)" /></div>
      <div><button type="submit">Calculate</button></div>
    </form>
    <p>Watt/Kg: {{ wattPerKg.toFixed(2) }}</p>
    <p>Average speed: {{ averageSpeed.toFixed(2) }} km/h</p>
    <!-- Graphs for weight loss and watt increase -->
    <div>
      <h3>Time Gain with Weight Loss</h3>
      <canvas id="weightLossGraph"></canvas>
    </div>
    <div>
      <h3>Time Gain with Watt Increase</h3>
      <canvas id="wattIncreaseGraph"></canvas>
    </div>
  </div>
</template>

<script>
import Chart from 'chart.js/auto';

export default {
  data() {
    return {
      // Initialize form fields with defaults or values from localStorage
      distance: localStorage.getItem('distance') || 0,
      timeRecord: localStorage.getItem('timeRecord') || '',
      averageWatts: localStorage.getItem('averageWatts') || 0,
      cyclistWeight: localStorage.getItem('cyclistWeight') || 0,

      wattPerKg: 0,
      averageSpeed: 0,
      weightLossChart: null,
      wattIncreaseChart: null,
    };
  },
  methods: {
    calculate() {
      // Store form fields in localStorage
      localStorage.setItem('distance', this.distance);
      localStorage.setItem('timeRecord', this.timeRecord);
      localStorage.setItem('averageWatts', this.averageWatts);
      localStorage.setItem('cyclistWeight', this.cyclistWeight);

      this.wattPerKg = this.averageWatts / this.cyclistWeight;
      this.timeSpendInSeconds = this.timeStringToSeconds(this.timeRecord);
      this.averageSpeed = this.getAverageSpeed(this.distance, this.timeSpendInSeconds);

      this.setupWeightLossGraph();
      this.setupWattIncreaseGraph();
    },
    getAverageSpeed(distance, timeSpendInSeconds) {
      return parseFloat(distance) / timeSpendInSeconds * 3600;
    },
    timeStringToSeconds(timeString) {
      const parts = timeString.split(':').map(part => parseInt(part, 10));
      let seconds = 0;
      if (parts.length === 3) {
        seconds = parts[0] * 3600 + parts[1] * 60 + parts[2];
      } else if (parts.length === 2) {
        seconds = parts[0] * 60 + parts[1];
      } else {
        // Invalid format, handle accordingly, e.g., show an error message
        console.error('Invalid time format');
        return null; // Or handle as appropriate for your application
      }
      console.log(seconds);
      return seconds;
    },
    setupWeightLossGraph() {
      const labels = []; // Labels for the x-axis
      const data = []; // Data for time gain

      // Example calculation (replace with your actual logic)
      for (let kg = Number(this.cyclistWeight); kg >= this.cyclistWeight - 10; kg -= 1) {
        labels.push(`${kg} kg`);
        data.push(this.getTimeGain(this.averageWatts, kg));
      }

      this.renderChart('weightLossGraph', 'Time Gain with Weight Loss', labels, data);
    },
    setupWattIncreaseGraph() {
      const labels = []; // Labels for the x-axis
      const data = []; // Data for time gain
      for (let watts = Number(this.averageWatts); watts <= Number(this.averageWatts) + 100; watts += 10) {
        labels.push(`${watts} watts`);
        data.push(this.getTimeGain(watts, this.cyclistWeight));
      }

      this.renderChart('wattIncreaseGraph', 'Time Gain with Watt Increase', labels, data);
    },
    renderChart(canvasId, title, labels, data) {
      // Check if the chart instance already exists
      if (this[canvasId] instanceof Chart) {
        this[canvasId].destroy(); // Destroy the existing chart
      }

      const ctx = document.getElementById(canvasId).getContext('2d');
      new Chart(ctx, {
        type: 'line',
        data: {
          labels: labels,
          datasets: [{
            label: title,
            data: data,
            fill: false,
            borderColor: 'rgb(75, 192, 192)',
            tension: 0.1
          }]
        },
        options: {
          scales: {
            y: {
              beginAtZero: true
            }
          }
        }
      });
    },
    getTimeGain(watts, kg) {
      let increasedAvgSpeed = (watts / kg) * this.averageSpeed / this.wattPerKg;
      let newTimeSpendInSec = increasedAvgSpeed * this.timeSpendInSeconds / this.averageSpeed;
      return this.timeSpendInSeconds - newTimeSpendInSec;
    }
  },
};
</script>
