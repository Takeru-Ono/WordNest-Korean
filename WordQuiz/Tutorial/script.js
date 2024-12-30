// Swiper initialization
const swiper = new Swiper('.swiper', {
  loop: false,
  navigation: {
    nextEl: '.swiper-button-next',
    prevEl: '.swiper-button-prev',
  },
  allowTouchMove: true,
});

const steps = [
  { relativeX: 0.06, relativeY: 0.03, relativeWidth: 0.41, relativeHeight: 0.35, text: "ここでは、日本語で問題が出題されます。それに当てはまる韓国語で答えるクイズです。" },
  { relativeX: 0.52, relativeY: 0.03, relativeWidth: 0.41, relativeHeight: 0.35, text: "ここでは、韓国語の音声付きで問題が出題されます。それに当てはまる日本語を答えるクイズです。" },
  { relativeX: 0.06, relativeY: 0.85, relativeWidth: 0.27, relativeHeight: 0.075, text: "収録されている単語はここで確認することができます。" },
  { relativeX: 0.36, relativeY: 0.85, relativeWidth: 0.27, relativeHeight: 0.075, text: "設定では、タイムアタックと数字クイズの時間制限を2−10秒でそれぞれ選択することができます。" }, // 新しいステップ4
  { relativeX: 0.65, relativeY: 0.85, relativeWidth: 0.27, relativeHeight: 0.075, text: "ここでは、お問い合わせや、ライセンス情報などを確認できます。このチュートリアルもここからいつでも見ることができます。" }, // 新しいステップ5
  { relativeX: 0.06, relativeY: 0.105, relativeWidth: 0.41, relativeHeight: 0.075, text: "まずはゆっくりモードを詳しく見ていきましょう。" } // 新しいステップ5
];

let currentStep = -1;

const highlightBox = document.getElementById("highlight-box");
const instruction = document.getElementById("instruction");
const nextButton = document.getElementById("next-button");
const imageElement = document.querySelector(".centered-image");

// Initialize highlight box position
function initializeHighlightBox() {
  const firstStep = steps[0]; // 最初のステップを取得
  const imageRect = imageElement.getBoundingClientRect();
  const containerRect = document.getElementById("tutorial-container").getBoundingClientRect();

  const left = imageRect.left - containerRect.left + firstStep.relativeX * imageRect.width;
  const top = imageRect.top - containerRect.top + firstStep.relativeY * imageRect.height;
  const width = firstStep.relativeWidth * imageRect.width;
  const height = firstStep.relativeHeight * imageRect.height;

  highlightBox.style.left = `${left}px`;
  highlightBox.style.top = `${top}px`;
  highlightBox.style.width = `${width}px`;
  highlightBox.style.height = `${height}px`;
  highlightBox.style.opacity = 0; // 初期状態では非表示
}

// Tutorial reset function
function resetTutorial() {
  currentStep = -1;
  initializeHighlightBox(); // 最初のステップの位置にリセット
  instruction.textContent = "ここがホーム画面です！";
  nextButton.style.display = "block";
}

// Update highlight box dimensions and position
function updateHighlightBox(step, options = {}) {
  const imageRect = options.imageElement 
    ? options.imageElement.getBoundingClientRect()
    : imageElement.getBoundingClientRect();

  const containerRect = document.getElementById(options.containerId || "tutorial-container").getBoundingClientRect();

  const left = imageRect.left - containerRect.left + step.relativeX * imageRect.width;
  const top = imageRect.top - containerRect.top + step.relativeY * imageRect.height;
  const width = step.relativeWidth * imageRect.width;
  const height = step.relativeHeight * imageRect.height;

  highlightBox.style.left = `${left}px`;
  highlightBox.style.top = `${top}px`;
  highlightBox.style.width = `${width}px`;
  highlightBox.style.height = `${height}px`;

  // アニメーションオプションの処理
  if (options.animate) {
    highlightBox.style.transition = "all 0.5s ease";
  } else {
    highlightBox.style.transition = "none";
  }

  highlightBox.style.opacity = options.show ? 1 : 0; // 表示・非表示を制御
}

function nextStep() {
  currentStep++;
  if (currentStep < steps.length) {
    const step = steps[currentStep];
    updateHighlightBox(step, { animate: true, show: true, containerId: "tutorial-container" });
    instruction.textContent = step.text;
  } else {
    // チュートリアルが終了したら次のスライドへ移動
    console.log("Moving to slide 3 and starting tutorial 3");

    // Swiperの次のスライドに移動
    swiper.slideNext();

    // スライド3のステップを強制的にリセット
    tutorial3CurrentStep = -1; // 初期状態にリセット

    // スライド3の初期化を一度だけ呼び出す
    setTimeout(() => {
      if (tutorial3CurrentStep === -1) {
        initializeTutorial3();
      } else {
        console.log("Tutorial 3 is already initialized.");
      }
    }, 300); // 適切な遅延時間を設定 (例: 500ms)
  }
}

// Move to the previous tutorial step
function prevStep() {
  // 現在のステップが最初のステップの場合は戻らない
  if (currentStep <= 0) {
    console.log("This is the first step. Cannot go back.");
    return;
  }

  // ステップを戻す
  currentStep--;

  // 現在のステップを取得
  const step = steps[currentStep];

  // ハイライトボックスを更新
  updateHighlightBox(step);

  // 説明文を更新
  instruction.textContent = step.text;

  // 次へボタンを再表示（もし隠されている場合）
  nextButton.style.display = "block";

  console.log(`Moved to step ${currentStep}`);
}

// 「前へ」ボタンのイベントリスナーを設定
document.getElementById("prev-button").addEventListener("click", prevStep);

// Resize observer for the image element
const resizeObserver = new ResizeObserver(() => {
  if (currentStep >= 0 && currentStep < steps.length) {
    updateHighlightBox(steps[currentStep]);
  } else if (currentStep === -1) {
    initializeHighlightBox(); // 最初のステップの位置を再計算
  }
});

// Observe the image element for resizing
resizeObserver.observe(imageElement);

// Event listener for the 'Next' button
nextButton.addEventListener("click", nextStep);

// Handle Start Tutorial Button
document.getElementById("start-tutorial").addEventListener("click", () => {
  swiper.slideTo(1);
  resetTutorial();
});






const tutorial3Steps = [
  {
    imageId: "image2",
    text: "カテゴリーを選択できます。初級単語を約1900単語収録しており、10単語ごとに分けられています。",
    highlightId: null
  },
  {
    imageId: "image2",
    text: "各カテゴリーでは、プレイした日付を確認できます。",
    highlightId: "highlight-box3",
    highlightStyle: { relativeX: 0.038, relativeY: 0.135, relativeWidth: 0.215, relativeHeight: 0.108 }
  },
  {
    imageId: "image3",
    text: "４択の中から答えを選んでください。",
    highlightId: "highlight-box3",
    highlightStyle: { relativeX: 0.039, relativeY: 0.489, relativeWidth: 0.918, relativeHeight: 0.394 }
  },
  {
    imageId: "image4",
    text: "間違えると、選択肢が赤くなります。正解するまで、次の画面には移動できません。",
    highlightId: "highlight-box3",
    highlightStyle: { relativeX: 0.039, relativeY: 0.489, relativeWidth: 0.918, relativeHeight: 0.394 }
  },
  {
    imageId: "image5",
    text: "正解の選択肢を、例文とともに確認できます。",
    highlightId: "highlight-box3",
    highlightStyle: { relativeX: 0.039, relativeY: 0.036, relativeWidth: 0.918, relativeHeight: 0.429 }
  },
  {
    imageId: "image5",
    text: "その他の選択肢の意味も確認できます。画面をタップすることで次の問題に移動します。",
    highlightId: "highlight-box3",
    highlightStyle: { relativeX: 0.039, relativeY: 0.489, relativeWidth: 0.918, relativeHeight: 0.324 }
  },
  {
    imageId: "image6",
    text: "10問終えると、この終了画面が出てきて、解答の確認することができます。",
    highlightId: null
  },
  {
    imageId: "image6",
    text: "タップすることで、意味と例文が出現するので、復習にご活用ください。",
    highlightId: "highlight-box3",
    highlightStyle: { relativeX: 0.013, relativeY: 0.065, relativeWidth: 0.864, relativeHeight: 0.086 }
  },
  {
    imageId: "image7",
    text: "もう一度タップすると収納されます。",
    highlightId: "highlight-box3",
    highlightStyle: { relativeX: 0.013, relativeY: 0.075, relativeWidth: 0.864, relativeHeight: 0.145 }
  },
  {
    imageId: "image7",
    text: "この星マークを押すと、苦手単語辞書に登録されます。",
    highlightId: "highlight-box3",
    highlightStyle: { relativeX: 0.874, relativeY: 0.078, relativeWidth: 0.095, relativeHeight: 0.055 }
  },
  {
    imageId: "image7",
    text: "カテゴリー選択画面に戻る場合は、ここを押してください。",
    highlightId: "highlight-box3",
    highlightStyle: { relativeX: 0.219, relativeY: 0.826, relativeWidth: 0.554, relativeHeight: 0.055 } // Relative values
  },
  {
    imageId: "image7",
    text: "ホームに戻る場合は、ここを押してください。",
    highlightId: "highlight-box3",
    highlightStyle: { relativeX: 0.26, relativeY: 0.88, relativeWidth: 0.45, relativeHeight: 0.055 } // Relative values
  }
];



let tutorial3CurrentStep = -1;

// ハイライトボックスの位置とサイズを更新する関数
function updateHighlightBox3(step, options = { animate: true, show: true, containerId: "tutorial-container-3" }) {
  const imageElement = document.getElementById(step.imageId || "image2");
  const highlightBox = document.getElementById("highlight-box3");
  const container = document.getElementById(options.containerId);

  if (!imageElement || !highlightBox || !container) {
    console.error("Missing elements for updateHighlightBox");
    return;
  }

  const imageRect = imageElement.getBoundingClientRect();
  const containerRect = container.getBoundingClientRect();

  // Calculate the position and size
  const left = (imageRect.left - containerRect.left) + step.relativeX * imageRect.width;
  const top = (imageRect.top - containerRect.top) + step.relativeY * imageRect.height;
  const width = step.relativeWidth * imageRect.width;
  const height = step.relativeHeight * imageRect.height;

  // Apply styles
  highlightBox.style.transition = options.animate ? "all 0.5s ease" : "none";
  highlightBox.style.left = `${left}px`;
  highlightBox.style.top = `${top}px`;
  highlightBox.style.width = `${width}px`;
  highlightBox.style.height = `${height}px`;
  highlightBox.style.opacity = options.show ? 1 : 0;
  highlightBox.style.visibility = options.show ? "visible" : "hidden";
}

function initializeTutorial3() {
  // ステップを初期化
  tutorial3CurrentStep = 0;

  const instruction3 = document.getElementById("instruction3");
  if (instruction3) {
    instruction3.style.display = "block";
  }

  // すべての画像を非表示にリセット
  const allImages = document.querySelectorAll("#tutorial-container-3 img");
  allImages.forEach(image => {
    image.classList.add("hidden");  // 非表示
    image.classList.remove("visible");
    image.style.opacity = 0;       // 完全に見えない状態に
    image.style.zIndex = 0;        // 背面に移動
  });

  // ステップ1の画像を前面に表示
  const firstStep = tutorial3Steps[tutorial3CurrentStep];
  if (firstStep.imageId) {
    const firstImage = document.getElementById(firstStep.imageId);
    if (firstImage) {
      firstImage.classList.remove("hidden"); // 表示
      firstImage.classList.add("visible");
      firstImage.style.opacity = 1;         // 完全に見える状態に
      firstImage.style.zIndex = 1;          // 前面に移動
    }
  }

  // ハイライトボックスを初期化
  const highlightBox = document.getElementById("highlight-box3");
  if (highlightBox && firstStep.highlightId) {
    highlightBox.style.top = firstStep.highlightStyle.top;
    highlightBox.style.left = firstStep.highlightStyle.left;
    highlightBox.style.width = firstStep.highlightStyle.width;
    highlightBox.style.height = firstStep.highlightStyle.height;
    highlightBox.style.opacity = 1;
    highlightBox.style.visibility = "visible";
  } else if (highlightBox) {
    highlightBox.style.opacity = 0;
    highlightBox.style.visibility = "hidden";
  }

  // 説明文を初期化
  document.getElementById("instruction3").textContent = firstStep.text;
}


function nextTutorial3Step() {

  const instruction3 = document.getElementById("instruction3");
  if (instruction3) {
    instruction3.style.display = "block";
  }

  if (tutorial3CurrentStep < tutorial3Steps.length - 1) {
    // すべての画像を非表示
    const allImages = document.querySelectorAll("#tutorial-container-3 img");
    allImages.forEach(image => {
      image.classList.add("hidden");
      image.classList.remove("visible");
      image.style.opacity = 0;
      image.style.zIndex = 0;
    });

    // 現在のステップを進める
    tutorial3CurrentStep++;

    const nextStep = tutorial3Steps[tutorial3CurrentStep];

    // 次のステップの画像を表示
    if (nextStep.imageId) {
      const nextImage = document.getElementById(nextStep.imageId);
      if (nextImage) {
        nextImage.classList.remove("hidden");
        nextImage.classList.add("visible");
        nextImage.style.opacity = 1; // 表示
        nextImage.style.zIndex = 1; // 前面
      } else {
      }
    }

if (nextStep.highlightId) {
  updateHighlightBox3(nextStep.highlightStyle, {
    animate: true,
    show: true,
    containerId: "tutorial-container-3",
  });
} else {
  const highlightBox = document.getElementById("highlight-box3");
  if (highlightBox) {
    highlightBox.style.opacity = 0;
    highlightBox.style.visibility = "hidden";
  }
}
    // 説明文を更新
    document.getElementById("instruction3").textContent = nextStep.text;
  } else {
    swiper.slideNext();

        // スライド4のステップを強制的にリセット
        tutorial4CurrentStep = -1; // 初期状態にリセット

        // スライド4の初期化を一度だけ呼び出す
        setTimeout(() => {
          if (tutorial4CurrentStep === -1) {
            initializeTutorial4();
          } else {
            console.log("Tutorial 4 is already initialized.");
          }
        }, 300); // 適切な遅延時間を設定 (例: 500ms)
  }
}

function prevTutorial3Step() {
  if (tutorial3CurrentStep > -1) {
    // 現在のステップを取得
    const currentStep = tutorial3Steps[tutorial3CurrentStep];

    // 画像の非表示
    if (currentStep.imageId) {
      const currentImage = document.getElementById(currentStep.imageId);
      if (currentImage) {
        currentImage.classList.add("hidden");
        currentImage.classList.remove("visible");
      }
    }

    // ハイライトボックスを非表示
    const highlightBox = document.getElementById("highlight-box3");
    if (highlightBox) {
      highlightBox.style.opacity = 0;
      highlightBox.style.visibility = "hidden";
    }

    // ステップを戻す
    tutorial3CurrentStep--;

    if (tutorial3CurrentStep >= 0) {
      const prevStep = tutorial3Steps[tutorial3CurrentStep];

      // 前の画像を表示
      if (prevStep.imageId) {
        const prevImage = document.getElementById(prevStep.imageId);
        if (prevImage) {
          prevImage.classList.remove("hidden");
          prevImage.classList.add("visible");
          prevImage.style.opacity = 1; // 表示
          prevImage.style.zIndex = 1; // 前面に移動
        }
      }

      if (prevStep.highlightId) {
        updateHighlightBox3(prevStep.highlightStyle, {
          animate: true,
          show: true,
          containerId: "tutorial-container-3",
        });
      }

      // 説明文を更新
      document.getElementById("instruction3").textContent = prevStep.text;
    } else {
      // 初期状態に戻す
      initializeTutorial3();
    }
  }
}

// Recalculate and update highlight box on window resize
window.addEventListener("resize", () => {
  if (tutorial3CurrentStep >= 0 && tutorial3CurrentStep < tutorial3Steps.length) {
    const currentStep = tutorial3Steps[tutorial3CurrentStep];
    if (currentStep.highlightId) {
      updateHighlightBox3(currentStep.highlightStyle, {
        animate: false,
        show: true,
        containerId: "tutorial-container-3",
      });
    }
  }
});

// ページロード時にイベントリスナーを設定
document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("prev-button3").addEventListener("click", prevTutorial3Step);
  document.getElementById("next-button3").addEventListener("click", nextTutorial3Step);
});




//スライド４のJS
const tutorial4Steps = [
  {
    imageId: "image8",
    text: "次にタイムアタックについて説明します。この右上のびっくりマークは後ほど詳しく解説します。",
    highlightId: "highlight-box4",
    highlightStyle: { relativeX: 0.06, relativeY: 0.185, relativeWidth: 0.41, relativeHeight: 0.075 }
  },
  {
    imageId: "image9",
    text: "カテゴリーを選択できます。収録されている単語は、ゆっくりモードと共通です。",
    highlightId: "highlight-box4",
    highlightStyle: { relativeX: 0.063, relativeY: 0.135, relativeWidth: 0.214, relativeHeight: 0.108 }
  },
  {
    imageId: "image9",
    text: "先ほどと同様、各カテゴリーでは、プレイした日付を確認できます。",
    highlightId: "highlight-box4",
    highlightStyle: { relativeX: 0.063, relativeY: 0.135, relativeWidth: 0.214, relativeHeight: 0.108 }
  },
  {
    imageId: "image9",
    text: "ここにもびっくりマークがありますが、これは復習マークです。クイズ終了後に、出来を自分で評価することで、次の復習する日が自動的に決まります。",
    highlightId: "highlight-box4",
    highlightStyle: { relativeX: 0.22, relativeY: 0.24, relativeWidth: 0.06, relativeHeight: 0.04 }
  },
  {
    imageId: "image9",
    text: "今日がその復習予定日を過ぎている場合、ここにびっくりマークが表示されます。",
    highlightId: "highlight-box4",
    highlightStyle: { relativeX: 0.22, relativeY: 0.24, relativeWidth: 0.06, relativeHeight: 0.04 }
  },
  {
    imageId: "image9",
    text: "１つでも復習マークがついているカテゴリーがあればホーム画面にもこのマークが表示されます。",
    highlightId: null
  },
  {
    imageId: "image10",
    text: "クイズ画面と内容は、ゆっくりモードと変わりません。しかし、問題はシャッフルされ、解答した段階で、次の問題に移動します。",
    highlightId: "highlight-box4",
    highlightStyle: { relativeX: 0.07, relativeY: 0.488, relativeWidth: 0.845, relativeHeight: 0.394 }
  },
  {
    imageId: "image10",
    text: "時間制限も設けているので、これが０になると、次の問題に移動します。",
    highlightId: "highlight-box4",
    highlightStyle: { relativeX: 0.73, relativeY: 0.092, relativeWidth: 0.14, relativeHeight: 0.077 }
  },
  {
    imageId: "image11",
    text: "10問終えるとこの画面になり、何問正解したかを確認できます。",
    highlightId: "highlight-box4",
    highlightStyle: { relativeX: 0.26, relativeY: 0.02, relativeWidth: 0.44, relativeHeight: 0.038 }
  },
  {
    imageId: "image11",
    text: "どの問題が正解だったかを、ここで確認できます。",
    highlightId: "highlight-box4",
    highlightStyle: { relativeX: 0.06, relativeY: 0.08, relativeWidth: 0.06, relativeHeight: 0.6 }
  },
  {
    imageId: "image11",
    text: "タップで、意味や例文を確認することもできます。",
    highlightId: "highlight-box4",
    highlightStyle: { relativeX: 0.039, relativeY: 0.08, relativeWidth: 0.8, relativeHeight: 0.06 }
  },
  {
    imageId: "image11",
    text: "苦手単語として登録すると、ゆっくりモードに連携されます。ただし、🇯🇵→🇰🇷と🇰🇷→🇯🇵ではそれぞれ別々に保存されます。",
    highlightId: "highlight-box4",
    highlightStyle: { relativeX: 0.84, relativeY: 0.08, relativeWidth: 0.085, relativeHeight: 0.04 }
  },
  {
    imageId: "image11",
    text: "クイズを終えた回数も見ることができます。",
    highlightId: "highlight-box4",
    highlightStyle: { relativeX: 0.039, relativeY: 0.7, relativeWidth: 0.9, relativeHeight: 0.03 }
  },
  {
    imageId: "image11",
    text: "このボタンが評価ボタンです。例えば、全然できなかったを押すと復習マーク（びっくりマーク）が即座につきます。",
    highlightId: "highlight-box4",
    highlightStyle: { relativeX: 0.039, relativeY: 0.74, relativeWidth: 0.9, relativeHeight: 0.086 }
  },
  {
    imageId: "image11",
    text: "左から、復習日までの期間は、即座、１日後、３日後、７日後です。",
    highlightId: "highlight-box4",
    highlightStyle: { relativeX: 0.039, relativeY: 0.74, relativeWidth: 0.9, relativeHeight: 0.086 }
  },
  {
    imageId: "image11",
    text: "この期間は私の独断と偏見で決めたので、増やして欲しいなどの声がありましたら、検討いたします。",
    highlightId: "highlight-box4",
    highlightStyle: { relativeX: 0.039, relativeY: 0.74, relativeWidth: 0.9, relativeHeight: 0.086 }
  },
  {
    imageId: "image11",
    text: "このボタンをオンにすると、どの評価を選んでも、復習マークはつきません。復習マークがうるさく感じる場合にお使いください。",
    highlightId: "highlight-box4",
    highlightStyle: { relativeX: 0.039, relativeY: 0.835, relativeWidth: 0.9, relativeHeight: 0.09 }
  },
  {
    imageId: "image11",
    text: "評価ボタンを押すことで、カテゴリー選択画面に戻ります。復習日を設定する関係で、ホームには直接戻れません。すみません。",
    highlightId: "highlight-box4",
    highlightStyle: { relativeX: 0.039, relativeY: 0.74, relativeWidth: 0.9, relativeHeight: 0.086 }
  }
];



let tutorial4CurrentStep = -1;


// ハイライトボックスの位置とサイズを更新する関数
function updateHighlightBox4(step, options = { animate: true, show: true, containerId: "tutorial-container-3" }) {
  const imageElement = document.getElementById(step.imageId || "image8");
  const highlightBox = document.getElementById("highlight-box4");
  const container = document.getElementById(options.containerId);

  if (!imageElement || !highlightBox || !container) {
    console.error("Missing elements for updateHighlightBox");
    return;
  }

  const imageRect = imageElement.getBoundingClientRect();
  const containerRect = container.getBoundingClientRect();

  // Calculate the position and size
  const left = (imageRect.left - containerRect.left) + step.relativeX * imageRect.width;
  const top = (imageRect.top - containerRect.top) + step.relativeY * imageRect.height;
  const width = step.relativeWidth * imageRect.width;
  const height = step.relativeHeight * imageRect.height;

  // Apply styles
  highlightBox.style.transition = options.animate ? "all 0.5s ease" : "none";
  highlightBox.style.left = `${left}px`;
  highlightBox.style.top = `${top}px`;
  highlightBox.style.width = `${width}px`;
  highlightBox.style.height = `${height}px`;
  highlightBox.style.opacity = options.show ? 1 : 0;
  highlightBox.style.visibility = options.show ? "visible" : "hidden";
}


function initializeTutorial4() {
  // ステップを初期化
  tutorial4CurrentStep = 0;

  const instruction4 = document.getElementById("instruction4");
  if (instruction4) {
    instruction4.style.display = "block";
  }

  // すべての画像を非表示にリセット
  const allImages = document.querySelectorAll("#tutorial-container-4 img");
  allImages.forEach(image => {
    image.classList.add("hidden");  // 非表示
    image.classList.remove("visible");
    image.style.opacity = 0;       // 完全に見えない状態に
    image.style.zIndex = 0;        // 背面に移動
  });

  // ステップ1の画像を前面に表示
  const firstStep = tutorial4Steps[tutorial4CurrentStep];
  if (firstStep.imageId) {
    const firstImage = document.getElementById(firstStep.imageId);
    if (firstImage) {
      firstImage.classList.remove("hidden"); // 表示
      firstImage.classList.add("visible");
      firstImage.style.opacity = 1;         // 完全に見える状態に
      firstImage.style.zIndex = 1;          // 前面に移動
    }
  }

  // ハイライトボックスを初期化
  const highlightBox = document.getElementById("highlight-box4");
  if (highlightBox && firstStep.highlightId) {
    highlightBox.style.top = firstStep.highlightStyle.top;
    highlightBox.style.left = firstStep.highlightStyle.left;
    highlightBox.style.width = firstStep.highlightStyle.width;
    highlightBox.style.height = firstStep.highlightStyle.height;
    highlightBox.style.opacity = 1;
    highlightBox.style.visibility = "visible";
  } else if (highlightBox) {
    highlightBox.style.opacity = 0;
    highlightBox.style.visibility = "hidden";
  }

  // 説明文を初期化
  document.getElementById("instruction4").textContent = firstStep.text;
}


function nextTutorial4Step() {

  const instruction4 = document.getElementById("instruction4");
  if (instruction4) {
    instruction4.style.display = "block";
  }


  if (tutorial4CurrentStep < tutorial4Steps.length - 1) {
    // すべての画像を非表示
    const allImages = document.querySelectorAll("#tutorial-container-4 img");
    allImages.forEach(image => {
      image.classList.add("hidden");
      image.classList.remove("visible");
      image.style.opacity = 0;
      image.style.zIndex = 0;
    });

    // 現在のステップを進める
    tutorial4CurrentStep++;

    const nextStep = tutorial4Steps[tutorial4CurrentStep];

    // 次のステップの画像を表示
    if (nextStep.imageId) {
      const nextImage = document.getElementById(nextStep.imageId);
      if (nextImage) {
        nextImage.classList.remove("hidden");
        nextImage.classList.add("visible");
        nextImage.style.opacity = 1; // 表示
        nextImage.style.zIndex = 1; // 前面
      } else {
      }
    }

if (nextStep.highlightId) {
  updateHighlightBox4(nextStep.highlightStyle, {
    animate: true,
    show: true,
    containerId: "tutorial-container-4",
  });
} else {
  const highlightBox = document.getElementById("highlight-box4");
  if (highlightBox) {
    highlightBox.style.opacity = 0;
    highlightBox.style.visibility = "hidden";
  }
}
    // 説明文を更新
    document.getElementById("instruction4").textContent = nextStep.text;
  } else {
    swiper.slideNext();

            // スライド5のステップを強制的にリセット
            tutorial5CurrentStep = -1; // 初期状態にリセット

            // スライド4の初期化を一度だけ呼び出す
            setTimeout(() => {
              if (tutorial5CurrentStep === -1) {
                initializeTutorial5();
              } else {
                console.log("Tutorial 5 is already initialized.");
              }
            }, 300); // 適切な遅延時間を設定 (例: 500ms)


  }
}

function prevTutorial4Step() {
  if (tutorial4CurrentStep > 0) {
    // 現在のステップを取得
    const currentStep = tutorial4Steps[tutorial4CurrentStep];

    // 現在のステップの画像を非表示
    if (currentStep.imageId) {
      const currentImage = document.getElementById(currentStep.imageId);
      if (currentImage) {
        currentImage.classList.add("hidden");
        currentImage.classList.remove("visible");
        currentImage.style.opacity = 0;
        currentImage.style.zIndex = 0;
      }
    }

    // ハイライトボックスを非表示
    const highlightBox = document.getElementById("highlight-box4");
    if (highlightBox) {
      highlightBox.style.opacity = 0;
      highlightBox.style.visibility = "hidden";
    }

    // ステップを戻す
    tutorial4CurrentStep--;

    if (tutorial4CurrentStep >= 0) {
      const prevStep = tutorial4Steps[tutorial4CurrentStep];

      // 前のステップの画像を表示
      if (prevStep.imageId) {
        const prevImage = document.getElementById(prevStep.imageId);
        if (prevImage) {
          prevImage.classList.remove("hidden");
          prevImage.classList.add("visible");
          prevImage.style.opacity = 1;
          prevImage.style.zIndex = 1;
        }
      }

      // 前のステップにハイライトボックスを更新
      if (prevStep.highlightId) {
        updateHighlightBox4(prevStep.highlightStyle, {
          animate: true,
          show: true,
          containerId: "tutorial-container-4",
        });
      }

      // 説明文を更新
      document.getElementById("instruction4").textContent = prevStep.text;

      console.log(`Moved to step ${tutorial4CurrentStep}`);
    } else {
      // 初期状態に戻す
      initializeTutorial4();
    }
  } else {
    console.log("This is the first step. Cannot go back.");
  }
}

// Recalculate and update highlight box on window resize
window.addEventListener("resize", () => {
  if (tutorial4CurrentStep >= 0 && tutorial4CurrentStep < tutorial4Steps.length) {
    const currentStep = tutorial4Steps[tutorial4CurrentStep];
    if (currentStep.highlightId) {
      updateHighlightBox4(currentStep.highlightStyle, {
        animate: false,
        show: true,
        containerId: "tutorial-container-4",
      });
    }
  }
});

// ページロード時にイベントリスナーを設定
document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("prev-button4").addEventListener("click", prevTutorial4Step);
  document.getElementById("next-button4").addEventListener("click", nextTutorial4Step);
});






//スライド５のJS
const tutorial5Steps = [
  {
    imageId: "image12",
    text: "次に数字クイズについて説明します。",
    highlightId: "highlight-box5",
    highlightStyle: { relativeX: 0.06, relativeY: 0.268, relativeWidth: 0.4, relativeHeight: 0.075 }
  },
  {
    imageId: "image13",
    text: "カテゴリーはこのように分けられています。",
    highlightId: "highlight-box5",
    highlightStyle: { relativeX: 0.063, relativeY: 0.13, relativeWidth: 0.86, relativeHeight: 0.485}
  },
  {
    imageId: "image13",
    text: "漢数詞は103問、固有数詞99問あります。問題数が多いですが、ご了承ください。🙏",
    highlightId: "highlight-box5",
    highlightStyle: { relativeX: 0.063, relativeY: 0.13, relativeWidth: 0.86, relativeHeight: 0.16 }
  },
  {
    imageId: "image13",
    text: "他のカテゴリーは、月日や時間などのクイズがランダムで生成されます。",
    highlightId: "highlight-box5",
    highlightStyle: { relativeX: 0.063, relativeY: 0.29, relativeWidth: 0.86, relativeHeight: 0.325 }
  },
  {
    imageId: "image13",
    text: "各クイズは10問ずつ生成され、タイムアタック同様に時間制限があります。制限時間は、設定画面から調整可能です。",
    highlightId: "highlight-box5",
    highlightStyle: { relativeX: 0.063, relativeY: 0.29, relativeWidth: 0.86, relativeHeight: 0.325 }
  },
  {
    imageId: "image13",
    text: "クイズ画面は基本的に同じ内容のため、詳細は省略させていただきます。",
    highlightId: null
  }
];

let tutorial5CurrentStep = -1;

 
// ハイライトボックスの位置とサイズを更新する関数
function updateHighlightBox5(step, options = { animate: true, show: true, containerId: "tutorial-container-3" }) {
  const imageElement = document.getElementById(step.imageId || "image12");
  const highlightBox = document.getElementById("highlight-box5");
  const container = document.getElementById(options.containerId);

  if (!imageElement || !highlightBox || !container) {
    console.error("Missing elements for updateHighlightBox");
    return;
  }

  const imageRect = imageElement.getBoundingClientRect();
  const containerRect = container.getBoundingClientRect();

  // Calculate the position and size
  const left = (imageRect.left - containerRect.left) + step.relativeX * imageRect.width;
  const top = (imageRect.top - containerRect.top) + step.relativeY * imageRect.height;
  const width = step.relativeWidth * imageRect.width;
  const height = step.relativeHeight * imageRect.height;

  // Apply styles
  highlightBox.style.transition = options.animate ? "all 0.5s ease" : "none";
  highlightBox.style.left = `${left}px`;
  highlightBox.style.top = `${top}px`;
  highlightBox.style.width = `${width}px`;
  highlightBox.style.height = `${height}px`;
  highlightBox.style.opacity = options.show ? 1 : 0;
  highlightBox.style.visibility = options.show ? "visible" : "hidden";
}


function initializeTutorial5() {
  // ステップを初期化
  tutorial5CurrentStep = 0;

  const instruction5 = document.getElementById("instruction5");
  if (instruction5) {
    instruction5.style.display = "block";
  }

  // すべての画像を非表示にリセット
  const allImages = document.querySelectorAll("#tutorial-container-5 img");
  allImages.forEach(image => {
    image.classList.add("hidden");  // 非表示
    image.classList.remove("visible");
    image.style.opacity = 0;       // 完全に見えない状態に
    image.style.zIndex = 0;        // 背面に移動
  });

  // ステップ1の画像を前面に表示
  const firstStep = tutorial5Steps[tutorial5CurrentStep];
  if (firstStep.imageId) {
    const firstImage = document.getElementById(firstStep.imageId);
    if (firstImage) {
      firstImage.classList.remove("hidden"); // 表示
      firstImage.classList.add("visible");
      firstImage.style.opacity = 1;         // 完全に見える状態に
      firstImage.style.zIndex = 1;          // 前面に移動
    }
  }

  // ハイライトボックスを初期化
  const highlightBox = document.getElementById("highlight-box5");
  if (highlightBox && firstStep.highlightId) {
    highlightBox.style.top = firstStep.highlightStyle.top;
    highlightBox.style.left = firstStep.highlightStyle.left;
    highlightBox.style.width = firstStep.highlightStyle.width;
    highlightBox.style.height = firstStep.highlightStyle.height;
    highlightBox.style.opacity = 1;
    highlightBox.style.visibility = "visible";
  } else if (highlightBox) {
    highlightBox.style.opacity = 0;
    highlightBox.style.visibility = "hidden";
  }

  // 説明文を初期化
  document.getElementById("instruction5").textContent = firstStep.text;
}


function nextTutorial5Step() {

  const instruction5 = document.getElementById("instruction5");
  if (instruction5) {
    instruction5.style.display = "block";
  }


  if (tutorial5CurrentStep < tutorial5Steps.length - 1) {
    // すべての画像を非表示
    const allImages = document.querySelectorAll("#tutorial-container-5 img");
    allImages.forEach(image => {
      image.classList.add("hidden");
      image.classList.remove("visible");
      image.style.opacity = 0;
      image.style.zIndex = 0;
    });

    // 現在のステップを進める
    tutorial5CurrentStep++;

    const nextStep = tutorial5Steps[tutorial5CurrentStep];

    // 次のステップの画像を表示
    if (nextStep.imageId) {
      const nextImage = document.getElementById(nextStep.imageId);
      if (nextImage) {
        nextImage.classList.remove("hidden");
        nextImage.classList.add("visible");
        nextImage.style.opacity = 1; // 表示
        nextImage.style.zIndex = 1; // 前面
      } else {
      }
    }

if (nextStep.highlightId) {
  updateHighlightBox5(nextStep.highlightStyle, {
    animate: true,
    show: true,
    containerId: "tutorial-container-5",
  });
} else {
  const highlightBox = document.getElementById("highlight-box5");
  if (highlightBox) {
    highlightBox.style.opacity = 0;
    highlightBox.style.visibility = "hidden";
  }
}
    // 説明文を更新
    document.getElementById("instruction5").textContent = nextStep.text;
  } else {
    swiper.slideNext();
  }
}

function prevTutorial5Step() {
  if (tutorial5CurrentStep > 0) {
    // 現在のステップを取得
    const currentStep = tutorial5Steps[tutorial5CurrentStep];

    // 現在のステップの画像を非表示
    if (currentStep.imageId) {
      const currentImage = document.getElementById(currentStep.imageId);
      if (currentImage) {
        currentImage.classList.add("hidden");
        currentImage.classList.remove("visible");
        currentImage.style.opacity = 0;
        currentImage.style.zIndex = 0;
      }
    }

    // ハイライトボックスを非表示
    const highlightBox = document.getElementById("highlight-box5");
    if (highlightBox) {
      highlightBox.style.opacity = 0;
      highlightBox.style.visibility = "hidden";
    }

    // ステップを戻す
    tutorial5CurrentStep--;

    if (tutorial5CurrentStep >= 0) {
      const prevStep = tutorial5Steps[tutorial5CurrentStep];

      // 前のステップの画像を表示
      if (prevStep.imageId) {
        const prevImage = document.getElementById(prevStep.imageId);
        if (prevImage) {
          prevImage.classList.remove("hidden");
          prevImage.classList.add("visible");
          prevImage.style.opacity = 1;
          prevImage.style.zIndex = 1;
        }
      }

      // 前のステップにハイライトボックスを更新
      if (prevStep.highlightId) {
        updateHighlightBox5(prevStep.highlightStyle, {
          animate: true,
          show: true,
          containerId: "tutorial-container-5",
        });
      }

      // 説明文を更新
      document.getElementById("instruction5").textContent = prevStep.text;

      console.log(`Moved to step ${tutorial5CurrentStep}`);
    } else {
      // 初期状態に戻す
      initializeTutorial5();
    }
  } else {
    console.log("This is the first step. Cannot go back.");
  }
}

// Recalculate and update highlight box on window resize
window.addEventListener("resize", () => {
  if (tutorial5CurrentStep >= 0 && tutorial5CurrentStep < tutorial5Steps.length) {
    const currentStep = tutorial5Steps[tutorial5CurrentStep];
    if (currentStep.highlightId) {
      updateHighlightBox5(currentStep.highlightStyle, {
        animate: false,
        show: true,
        containerId: "tutorial-container-5",
      });
    }
  }
});

// ページロード時にイベントリスナーを設定
document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("prev-button5").addEventListener("click", prevTutorial5Step);
  document.getElementById("next-button5").addEventListener("click", nextTutorial5Step);
});







//スライド6のJS
const tutorial6Steps = [
  {
    imageId: "image14",
    text: "最後に、辞書画面について説明します",
    highlightId: "highlight-box6",
    highlightStyle: { relativeX: 0.06, relativeY: 0.85, relativeWidth: 0.27, relativeHeight: 0.07 }
  },
  {
    imageId: "image15",
    text: "辞書画面は次のように分類されています。",
    highlightId: "highlight-box6",
    highlightStyle: { relativeX: 0.09, relativeY: 0.13, relativeWidth: 0.8, relativeHeight: 0.55}
  },
  {
    imageId: "image15",
    text: "動詞・形容詞を含む辞書と、それ以外の辞書に分類しています。職業や旅行などのカテゴリ別には分けていません。",
    highlightId: "highlight-box6",
    highlightStyle: { relativeX: 0.09, relativeY: 0.13, relativeWidth: 0.8, relativeHeight: 0.55}
  },
  {
    imageId: "image16",
    text: "こちらが辞書画面です。",
    highlightId: null
  },
  {
    imageId: "image16",
    text: "検索機能は日本語と韓国語の両方に対応しています。",
    highlightId: "highlight-box6",
    highlightStyle: { relativeX: 0.063, relativeY: 0.13, relativeWidth: 0.64, relativeHeight: 0.06}
  },
  {
    imageId: "image16",
    text: "タップすると、意味と例文が表示されます。",
    highlightId: "highlight-box6",
    highlightStyle: { relativeX: 0.063, relativeY: 0.19, relativeWidth: 0.64, relativeHeight: 0.09}
  },
  {
    imageId: "image17",
    text: "もう一度タップすると閉じます。ただし、この操作時に不具合が発生する可能性があります。ご了承ください。",
    highlightId: "highlight-box6",
    highlightStyle: { relativeX: 0.063, relativeY: 0.19, relativeWidth: 0.64, relativeHeight: 0.17}
  },
  {
    imageId: "image18",
    text: "ソート機能では、韓国語順、日本語順、逆順に並べ替えることができます。",
    highlightId: "highlight-box6",
    highlightStyle: { relativeX: 0.32, relativeY: 0.18, relativeWidth: 0.63, relativeHeight: 0.28}
  }
];


let tutorial6CurrentStep = -1;

 
// ハイライトボックスの位置とサイズを更新する関数
function updateHighlightBox6(step, options = { animate: true, show: true, containerId: "tutorial-container-6" }) {
  const imageElement = document.getElementById(step.imageId || "image14");
  const highlightBox = document.getElementById("highlight-box6");
  const container = document.getElementById(options.containerId);

  if (!imageElement || !highlightBox || !container) {
    console.error("Missing elements for updateHighlightBox");
    return;
  }

  const imageRect = imageElement.getBoundingClientRect();
  const containerRect = container.getBoundingClientRect();

  // Calculate the position and size
  const left = (imageRect.left - containerRect.left) + step.relativeX * imageRect.width;
  const top = (imageRect.top - containerRect.top) + step.relativeY * imageRect.height;
  const width = step.relativeWidth * imageRect.width;
  const height = step.relativeHeight * imageRect.height;

  // Apply styles
  highlightBox.style.transition = options.animate ? "all 0.6s ease" : "none";
  highlightBox.style.left = `${left}px`;
  highlightBox.style.top = `${top}px`;
  highlightBox.style.width = `${width}px`;
  highlightBox.style.height = `${height}px`;
  highlightBox.style.opacity = options.show ? 1 : 0;
  highlightBox.style.visibility = options.show ? "visible" : "hidden";
}


function initializeTutorial6() {
  // ステップを初期化
  tutorial6CurrentStep = 0;

  const instruction6 = document.getElementById("instruction6");
  if (instruction6) {
    instruction6.style.display = "block";
  }

  // すべての画像を非表示にリセット
  const allImages = document.querySelectorAll("#tutorial-container-6 img");
  allImages.forEach(image => {
    image.classList.add("hidden");  // 非表示
    image.classList.remove("visible");
    image.style.opacity = 0;       // 完全に見えない状態に
    image.style.zIndex = 0;        // 背面に移動
  });

  // ステップ1の画像を前面に表示
  const firstStep = tutorial6Steps[tutorial6CurrentStep];
  if (firstStep.imageId) {
    const firstImage = document.getElementById(firstStep.imageId);
    if (firstImage) {
      firstImage.classList.remove("hidden"); // 表示
      firstImage.classList.add("visible");
      firstImage.style.opacity = 1;         // 完全に見える状態に
      firstImage.style.zIndex = 1;          // 前面に移動
    }
  }

  // ハイライトボックスを初期化
  const highlightBox = document.getElementById("highlight-box6");
  if (highlightBox && firstStep.highlightId) {
    highlightBox.style.top = firstStep.highlightStyle.top;
    highlightBox.style.left = firstStep.highlightStyle.left;
    highlightBox.style.width = firstStep.highlightStyle.width;
    highlightBox.style.height = firstStep.highlightStyle.height;
    highlightBox.style.opacity = 1;
    highlightBox.style.visibility = "visible";
  } else if (highlightBox) {
    highlightBox.style.opacity = 0;
    highlightBox.style.visibility = "hidden";
  }

  // 説明文を初期化
  document.getElementById("instruction6").textContent = firstStep.text;
}


function nextTutorial6Step() {

  const instruction6 = document.getElementById("instruction6");
  if (instruction6) {
    instruction6.style.display = "block";
  }


  if (tutorial6CurrentStep < tutorial6Steps.length - 1) {
    // すべての画像を非表示
    const allImages = document.querySelectorAll("#tutorial-container-6 img");
    allImages.forEach(image => {
      image.classList.add("hidden");
      image.classList.remove("visible");
      image.style.opacity = 0;
      image.style.zIndex = 0;
    });

    // 現在のステップを進める
    tutorial6CurrentStep++;

    const nextStep = tutorial6Steps[tutorial6CurrentStep];

    // 次のステップの画像を表示
    if (nextStep.imageId) {
      const nextImage = document.getElementById(nextStep.imageId);
      if (nextImage) {
        nextImage.classList.remove("hidden");
        nextImage.classList.add("visible");
        nextImage.style.opacity = 1; // 表示
        nextImage.style.zIndex = 1; // 前面
      } else {
      }
    }

if (nextStep.highlightId) {
  updateHighlightBox6(nextStep.highlightStyle, {
    animate: true,
    show: true,
    containerId: "tutorial-container-6",
  });
} else {
  const highlightBox = document.getElementById("highlight-box6");
  if (highlightBox) {
    highlightBox.style.opacity = 0;
    highlightBox.style.visibility = "hidden";
  }
}
    // 説明文を更新
    document.getElementById("instruction6").textContent = nextStep.text;
  } else {
    swiper.slideNext();
  }
}

function prevTutorial6Step() {
  if (tutorial6CurrentStep > 0) {
    // 現在のステップを取得
    const currentStep = tutorial6Steps[tutorial6CurrentStep];

    // 現在のステップの画像を非表示
    if (currentStep.imageId) {
      const currentImage = document.getElementById(currentStep.imageId);
      if (currentImage) {
        currentImage.classList.add("hidden");
        currentImage.classList.remove("visible");
        currentImage.style.opacity = 0;
        currentImage.style.zIndex = 0;
      }
    }

    // ハイライトボックスを非表示
    const highlightBox = document.getElementById("highlight-box6");
    if (highlightBox) {
      highlightBox.style.opacity = 0;
      highlightBox.style.visibility = "hidden";
    }

    // ステップを戻す
    tutorial6CurrentStep--;

    if (tutorial6CurrentStep >= 0) {
      const prevStep = tutorial6Steps[tutorial6CurrentStep];

      // 前のステップの画像を表示
      if (prevStep.imageId) {
        const prevImage = document.getElementById(prevStep.imageId);
        if (prevImage) {
          prevImage.classList.remove("hidden");
          prevImage.classList.add("visible");
          prevImage.style.opacity = 1;
          prevImage.style.zIndex = 1;
        }
      }

      // 前のステップにハイライトボックスを更新
      if (prevStep.highlightId) {
        updateHighlightBox6(prevStep.highlightStyle, {
          animate: true,
          show: true,
          containerId: "tutorial-container-6",
        });
      }

      // 説明文を更新
      document.getElementById("instruction6").textContent = prevStep.text;

      console.log(`Moved to step ${tutorial6CurrentStep}`);
    } else {
      // 初期状態に戻す
      initializeTutorial6();
    }
  } else {
    console.log("This is the first step. Cannot go back.");
  }
}

// Recalculate and update highlight box on window resize
window.addEventListener("resize", () => {
  if (tutorial6CurrentStep >= 0 && tutorial6CurrentStep < tutorial6Steps.length) {
    const currentStep = tutorial6Steps[tutorial6CurrentStep];
    if (currentStep.highlightId) {
      updateHighlightBox6(currentStep.highlightStyle, {
        animate: false,
        show: true,
        containerId: "tutorial-container-6",
      });
    }
  }
});

// ページロード時にイベントリスナーを設定
document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("prev-button6").addEventListener("click", prevTutorial6Step);
  document.getElementById("next-button6").addEventListener("click", nextTutorial6Step);
});





