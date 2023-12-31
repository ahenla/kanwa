import { Controller } from "@hotwired/stimulus"
import ApexCharts from 'apexcharts';

// Connects to data-controller="heatmap"
export default class extends Controller {
  static values = { yes: String, nots: String, situation: String }

  static targets = ["barchart"]

  connect() {

    console.log('i am connected');

    const yes = parseInt(this.yesValue, 10)
    const no = parseInt(this.notsValue, 10)
    const situation = this.situationValue

    console.log(this.situationValue);

    // const yesPercentage = parseInt((yes * 100) / (yes + no), 10)

    const yesPercentage = yes
    const noPercentage = 100 - yesPercentage

    console.log(noPercentage, yesPercentage);



    const options = {
      chart: {
        type: 'bar',
        height: 115,
        stacked: true,
        stackType: '100%',
        toolbar: {
          show: false,
          exportMenu: false,
        },
      },
      xaxis: {
        labels: {
          show: false,
        },
      },
      yaxis: {
        labels: {
          show: false,
        },
      },

      legend: {
        // labels: {
        //   colors: ['#F44336', '#E91E63']
        // },
        fontSize: '12px', // Adjust the font size here
        markers: {
          height: 15,
          width: 15,
          fillColors: ['#8AB2BB', '#EAB9B9'],
        },
      },
      fill: {
        colors: ['#8AB2BB', '#EAB9B9']
      },
      // legend: {
      //   show: false,
      // },
      plotOptions: {
        bar: {
          horizontal: true,
        },
      },
      title: {
        text: ['Your action control rate'],
        align: 'center',
        offsetY: 20, // Adjust the vertical offset if needed
        style: {
          fontSize: '16px', // Adjust the font size here
          fontWeight: 'normal',
          fontFamily: "Work Sans, Helvetica, sans-serif",
        },
      },
      series: [{
        name: "Controlled",
        data:
          [yesPercentage],
      }, {
        name: "Uncontrolled",
        data:
          [noPercentage]
      }]
    };
    var barchart = new ApexCharts(document.querySelector("#barchart"), options);
    barchart.render();
  }
}
