<!DOCTYPE html>
<html lang="{{ $contract->language ?? 'en' }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contract {{ $contract->contract_number }}</title>
    <style>
        @page { margin: 60px; size: A4; }
        body { font-family: 'DejaVu Sans', sans-serif; color: #1f2937; line-height: 1.6; font-size: 12px; }
        h1 { text-align: center; font-size: 22px; margin-bottom: 6px; }
        .sub { text-align: center; font-size: 11px; color: #6b7280; margin-bottom: 30px; }
        .section { margin-bottom: 18px; }
        .section-title { font-weight: 700; font-size: 13px; margin-bottom: 6px; text-transform: uppercase; border-bottom: 1px solid #e5e7eb; padding-bottom: 4px; }
        .row { margin-bottom: 4px; }
        .label { font-weight: 600; }
        .terms { text-align: justify; }
        .signature-box { margin-top: 40px; border-top: 1px solid #e5e7eb; padding-top: 12px; }
        .signature-img { max-height: 120px; max-width: 300px; margin-top: 8px; }
        .footer { margin-top: 60px; display: flex; justify-content: space-between; }
        .sign-line { border-top: 1px solid #374151; width: 200px; margin-top: 40px; padding-top: 4px; font-size: 11px; }
    </style>
</head>
@php $sw = ($contract->language ?? 'en') === 'sw'; @endphp
<body>
    <h1>{{ $sw ? 'MKATABA WA UPANGAJI' : 'TENANCY AGREEMENT' }}</h1>
    <p class="sub">{{ $sw ? 'Mkataba Namba' : 'Contract No' }}: {{ $contract->contract_number }} &bull; {{ $contract->contract_type === 'manual' ? ($sw ? 'Mwongozo' : 'Manual') : ($sw ? 'Kidijitali' : 'Digital') }}</p>

    <div class="section">
        <div class="section-title">{{ $sw ? '1. Pande' : '1. Parties' }}</div>
        <div class="row"><span class="label">{{ $sw ? 'Mmiliki:' : 'Landlord:' }}</span> {{ $contract->organization?->business_name ?? 'Manna Apartment' }}</div>
        <div class="row"><span class="label">{{ $sw ? 'Mpangaji:' : 'Tenant:' }}</span> {{ $contract->tenant?->user?->full_name ?? 'N/A' }}</div>
        <div class="row"><span class="label">{{ $sw ? 'Simu:' : 'Phone:' }}</span> {{ $contract->tenant?->user?->phone ?? 'N/A' }}</div>
    </div>

    <div class="section">
        <div class="section-title">{{ $sw ? '2. Mali' : '2. Property' }}</div>
        <div class="row"><span class="label">{{ $sw ? 'Mali:' : 'Property:' }}</span> {{ $contract->unit?->property?->name ?? 'N/A' }}</div>
        <div class="row"><span class="label">{{ $sw ? 'Anuani:' : 'Address:' }}</span> {{ $contract->unit?->property?->address ?? $contract->unit?->property?->location ?? 'N/A' }}</div>
        <div class="row"><span class="label">{{ $sw ? 'Kiwango:' : 'Unit:' }}</span> {{ $contract->unit?->name ?? $contract->unit?->unit_number ?? 'N/A' }}</div>
    </div>

    <div class="section">
        <div class="section-title">{{ $sw ? '3. Muda' : '3. Term' }}</div>
        <div class="row"><span class="label">{{ $sw ? 'Tarehe ya Kuanza:' : 'Start Date:' }}</span> {{ $contract->start_date?->format('d M Y') ?? 'N/A' }}</div>
        <div class="row"><span class="label">{{ $sw ? 'Tarehe ya Kumaliza:' : 'End Date:' }}</span> {{ $contract->end_date?->format('d M Y') ?? 'N/A' }}</div>
        <div class="row"><span class="label">{{ $sw ? 'Muda:' : 'Duration:' }}</span> {{ str_replace('_', ' ', $contract->duration_type) }}</div>
    </div>

    <div class="section">
        <div class="section-title">{{ $sw ? '4. Kodi' : '4. Rent' }}</div>
        <div class="row"><span class="label">{{ $sw ? 'Kodi ya Mwezi:' : 'Monthly Rent:' }}</span> TZS {{ number_format($contract->rent_amount, 0) }}</div>
        <div class="row"><span class="label">{{ $sw ? 'Dhamana:' : 'Deposit:' }}</span> TZS {{ number_format($contract->deposit_amount ?? 0, 0) }}</div>
    </div>

    <div class="section">
        <div class="section-title">{{ $sw ? '5. Masharti na Matakwa' : '5. Terms and Conditions' }}</div>
        @if($contract->contract_type === 'manual' && $contract->template_content)
        <p class="terms" style="white-space: pre-wrap;">{{ $contract->template_content }}</p>
        @elseif($sw)
        <p class="terms">
            Mpangaji atalipa kodi ya mwezi siku ya 5 au kabla ya tarehe hiyo ya kila mwezi. Kuchelewa kulipa kutasababisha faini itakayowekwa na Mmiliki. Mpangaji atatumia eneo hilo kwa madhumuni ya makazi tu na hataweza kupangisha wengine, kukabidhi, au kuhamisha sehemu yoyote ya eneo bila ridhaa ya maandishi ya Mmiliki. Mpangaji atatunza eneo hilo katika hali njema na safi na atawajibika kwa uharibifu wowote unaosababishwa na uzembe au matumizi mabaya, isipokuwa uharibifu wa kawaida wa matumizi. Mmiliki atawajibika kwa ukarabati wa miundombinu, mabomba, umeme, na matengenezo mengine makubwa. Upande wowote unaweza kusitisha mkataba huu kwa kutoa notisi ya maandishi ya mwezi mmoja (1). Baada ya kusitishwa, Mpangaji atakabidhi eneo hilo katika hali sawa, isipokuwa uharibifu wa kawaida. Dhamana itarejeshwa baada ya kutoa kodi au gharama za uharibifu.
        </p>
        @else
        <p class="terms">
            The Tenant shall pay the monthly rent on or before the 5th day of each calendar month. Late payment shall attract a penalty as determined by the Landlord. The Tenant shall use the premises for residential purposes only and shall not sub-let, assign, or transfer any part of the premises without prior written consent of the Landlord. The Tenant shall maintain the premises in good and clean condition and shall be responsible for any damage caused by negligence or misuse, excluding normal wear and tear. The Landlord shall be responsible for structural repairs, plumbing, electrical, and other major maintenance. Either party may terminate this agreement by giving one (1) month written notice. Upon termination, the Tenant shall hand over the premises in the same condition, fair wear and tear excepted. The security deposit shall be refunded after deduction of any outstanding rent or damage costs.
        </p>
        @endif
    </div>

    @if($signatureBase64)
    <div class="signature-box">
        <div class="section-title">{{ $sw ? 'Saini' : 'Signatures' }}</div>
        <div class="footer" style="margin-top: 20px;">
            <div>
                <div style="font-weight: 700; font-size: 12px; margin-bottom: 8px;">{{ $sw ? 'Mmiliki' : 'Landlord' }}</div>
                <img src="{{ $signatureBase64 }}" class="signature-img" alt="Landlord Signature">
                <div class="sign-line" style="margin-top: 8px;">{{ $sw ? 'Imesainiwa' : 'Signed on' }} {{ $contract->signed_at?->format('d M Y') ?? now()->format('d M Y') }}</div>
            </div>
            <div>
                <div style="font-weight: 700; font-size: 12px; margin-bottom: 8px;">{{ $sw ? 'Mpangaji' : 'Tenant' }}</div>
                <div class="sign-line" style="margin-top: 52px;">{{ $sw ? 'Saini ya Mpangaji' : 'Tenant Signature' }}</div>
            </div>
        </div>
    </div>
    @else
    <div class="footer">
        <div>
            <div class="sign-line">{{ $sw ? 'Saini ya Mmiliki' : 'Landlord Signature' }}</div>
        </div>
        <div>
            <div class="sign-line">{{ $sw ? 'Saini ya Mpangaji' : 'Tenant Signature' }}</div>
        </div>
    </div>
    @endif
</body>
</html>
