import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    dates: Array,
    values: Array
  }

  connect() {
    this.initChart()
  }

  initChart() {
    const ctx = this.canvasTarget.getContext('2d')

    new Chart(ctx, {
      type: 'line',
      data: {
        labels: this.datesValue,
        datasets: [{
          label: 'Mood',
          data: this.valuesValue,
          borderColor: 'rgb(79, 70, 229)',
          backgroundColor: 'rgba(79, 70, 229, 0.1)',
          fill: true,
          tension: 0.3,
          pointBackgroundColor: 'rgb(79, 70, 229)',
          pointRadius: 4,
          pointHoverRadius: 6
        }]
      },
      options: {
        scales: {
          y: {
            beginAtZero: true,
            max: 5,
            ticks: {
              stepSize: 1,
              callback: function(value) {
                const labels = ['', 'Very Low', 'Low', 'Neutral', 'Good', 'Excellent']
                return labels[value] || value
              }
            }
          }
        },
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            callbacks: {
              label: function(context) {
                const labels = ['Very Low', 'Low', 'Neutral', 'Good', 'Excellent']
                const value = context.parsed.y
                return `Mood: ${labels[value-1] || value}`
              }
            }
          }
        },
        maintainAspectRatio: false
      }
    })
  }
}
